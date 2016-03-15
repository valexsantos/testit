module TestitIssuesController
    include ProjectsHelper
    include CustomFieldsHelper
    #
    include TestitSortHelper
    include TestitQueriesHelper

    # GET display a list of all events
    # /photos
    def index
        # TODO FIX  Retirar estas inicializacoes dos settings
        @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)

        retrieve_query
        sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
        sort_update(@query.sortable_columns)
        @query.sort_criteria = sort_criteria.to_a

        if @query.valid?
            case params[:format]
            when 'csv', 'pdf'
                @limit = Setting.issues_export_limit.to_i
                if params[:columns] == 'all'
                    @query.column_names = @query.available_inline_columns.map(&:name)
                end
            when 'atom'
                @limit = Setting.feeds_limit.to_i
            when 'xml', 'json'
                @offset, @limit = api_offset_and_limit
                @query.column_names = %w(author)
            else
                @limit = per_page_option
            end

            @issue_count = @query.issue_count
            @issue_pages = Redmine::Pagination::Paginator.new @issue_count, @limit, params['page']
            @offset ||= @issue_pages.offset
            @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                    :order => sort_clause,
                                    :offset => @offset,
                                    :limit => @limit)
            @issue_count_by_group = @query.issue_count_by_group
        end
    end
    # GET display a specific event
    # /photos/:id
    def show
        @journals = @issue.journals.includes(:user, :details).
            references(:user, :details).
            reorder(:created_on, :id).to_a
        @journals.each_with_index {|j,i| j.indice = i+1}
        @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
        Journal.preload_journals_details_custom_fields(@journals)
        @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
        @journals.reverse! if User.current.wants_comments_in_reverse_order?

        @changesets = @issue.changesets.visible.preload(:repository, :user).to_a
        @changesets.reverse! if User.current.wants_comments_in_reverse_order?

        @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
        @priorities = IssuePriority.active
        @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
        @relation = IssueRelation.new
        @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
        @testit_relation = Testit::Relation.new
    end

    # GET return an HTML form for creating a new event
    # /photos/new
    def new
    end

    # GET return an HTML form for editing an event
    # /photos/:id/edit
    def edit
        return unless update_issue_from_params
    end

    # POST create a new event
    # /photos
    def create
        unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
            raise ::Unauthorized
        end
        @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
        @issue.save
    end
    # PUT update a specific event
    # /photos/:id
    def update
        return unless update_issue_from_params
        @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
        saved = false
        begin
            saved = save_issue_with_child_records
        rescue ActiveRecord::StaleObjectError
            @conflict = true
            if params[:last_journal_id]
                @conflict_journals = @issue.journals_after(params[:last_journal_id]).to_a
                @conflict_journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
            end
        end
        saved

    end
    # DELETE delete a specific event
    # /photos/:id
    def destroy
        @hours = TimeEntry.where(:issue_id => @issues.map(&:id)).sum(:hours).to_f
        if @hours > 0
            case params[:todo]
            when 'destroy'
                # nothing to do
            when 'nullify'
                TimeEntry.where(['issue_id IN (?)', @issues]).update_all('issue_id = NULL')
            when 'reassign'
                reassign_to = @project.issues.find_by_id(params[:reassign_to_id])
                if reassign_to.nil?
                    raise l(:error_issue_not_found_in_project)
                else
                    TimeEntry.where(['issue_id IN (?)', @issues]).
                        update_all("issue_id = #{reassign_to.id}")
                end
            else
                # display the destroy form if it's a user request
                return unless api_request?
            end
        end
        @issues.each do |issue|
            begin
                issue.reload.destroy
            rescue ::ActiveRecord::RecordNotFound # raised by #reload if issue no longer exists
                # nothing to do, issue was already deleted (eg. by a parent)
            end
        end
    end


    #
    # aux
    #
    def find_project
        begin
            @project = Project.find(params[:project_id])
        rescue ActiveRecord::RecordNotFound
            render_404
        end
    end

    # Used by #new and #create to build a new issue from the params
    # The new issue will be copied from an existing one if copy_from parameter is given
    def build_new_issue_from_params
        @issue = Issue.new
        if params[:copy_from]
            begin
                @issue.init_journal(User.current)
                @copy_from = Issue.visible.find(params[:copy_from])
                unless User.current.allowed_to?(:copy_issues, @copy_from.project)
                    raise ::Unauthorized
                end
                @link_copy = link_copy?(params[:link_copy]) || request.get?
                @copy_attachments = params[:copy_attachments].present? || request.get?
                @copy_subtasks = params[:copy_subtasks].present? || request.get?
                @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks, :link => @link_copy)
            rescue ActiveRecord::RecordNotFound
                render_404
                return
            end
        end
        @issue.project = @project
        if request.get?
            @issue.project ||= @issue.allowed_target_projects.first
        end
        @issue.author ||= User.current
        @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?

        attrs = (params[:issue] || {}).deep_dup
        if action_name == 'new' && params[:was_default_status] == attrs[:status_id]
            attrs.delete(:status_id)
        end
        if action_name == 'new' && params[:form_update_triggered_by] == 'issue_project_id'
            # Discard submitted version when changing the project on the issue form
            # so we can use the default version for the new project
            attrs.delete(:fixed_version_id)
        end
        @issue.safe_attributes = attrs

        if @issue.project
            @issue.tracker ||= @issue.project.trackers.first
            if @issue.tracker.nil?
                render_error l(:error_no_tracker_in_project)
                return false
            end
            if @issue.status.nil?
                render_error l(:error_no_default_issue_status)
                return false
            end
        end

        @priorities = IssuePriority.active
        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    end
    # Used by #edit and #update to set some common instance variables
    # from the params
    def update_issue_from_params
        @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
        if params[:time_entry]
            @time_entry.safe_attributes = params[:time_entry]
        end

        @issue.init_journal(User.current)

        issue_attributes = params[:issue]
        if issue_attributes && params[:conflict_resolution]
            case params[:conflict_resolution]
            when 'overwrite'
                issue_attributes = issue_attributes.dup
                issue_attributes.delete(:lock_version)
            when 'add_notes'
                issue_attributes = issue_attributes.slice(:notes)
            when 'cancel'
                redirect_to issue_path(@issue)
                return false
            end
        end
        @issue.safe_attributes = issue_attributes
        @priorities = IssuePriority.active
        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
        true
    end

    def save_issue_with_child_records
        Issue.transaction do
            if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, @issue.project)
                time_entry = @time_entry || TimeEntry.new
                time_entry.project = @issue.project
                time_entry.issue = @issue
                time_entry.user = User.current
                time_entry.spent_on = User.current.today
                time_entry.attributes = params[:time_entry]
                @issue.time_entries << time_entry
            end

            call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
            if @issue.save
                call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
            else
                raise ActiveRecord::Rollback
            end
        end
    end

    # Returns true if the issue copy should be linked
    # to the original issue
    def link_copy?(param)
        case Setting.link_copied_issue
        when 'yes'
            true
        when 'no'
            false
        when 'ask'
            param == '1'
        end
    end

    def retrieve_previous_and_next_issue_ids
        retrieve_query_from_session
        if @query
            sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
            sort_update(@query.sortable_columns, 'issues_index_sort')
            limit = 500
            issue_ids = @query.issue_ids(:order => sort_clause, :limit => (limit + 1), :include => [:assigned_to, :tracker, :priority, :category, :fixed_version])
            if (idx = issue_ids.index(@issue.id)) && idx < limit
                if issue_ids.size < 500
                    @issue_position = idx + 1
                    @issue_count = issue_ids.size
                end
                @prev_issue_id = issue_ids[idx - 1] if idx > 0
                @next_issue_id = issue_ids[idx + 1] if idx < (issue_ids.size - 1)
            end
        end
    end
end

