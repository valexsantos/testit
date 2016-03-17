require 'application_helper'

module TestitQueriesHelper
    include QueriesHelper

    #
    # requires testit_x_helper... ahahah
    #
    def column_value(column, issue, value)
        case column.name
        when :id
            link_to_function issue.id, "showIssue('#{url_for_show_testit_issue(issue)}');"
        when :subject
            link_to_function issue.subject, "showIssue('#{url_for_show_testit_issue(issue)}');"
        else
            super
        end
    end

    # to override in controllers
    def the_query
        {:key=>:query, :klass => IssueQuery}
    end

    def retrieve_query
        # params[:values][:tracker_id] = [ "#{@settings.test_case_tracker}", "#{@settings.test_suite_tracker}"]
        if !params[:query_id].blank?
            cond = "project_id IS NULL"
            cond << " OR project_id = #{@project.id}" if @project
            @query = the_query[:klass].where(cond).find(params[:query_id])
            raise ::Unauthorized unless @query.visible?
            @query.project = @project
            if @query.is_a?Testit::TestitQuery
                @query.build_available_filters_for_project
            end
            session[the_query[:key]] = {:id => @query.id, :project_id => @query.project_id}
            sort_clear
        elsif api_request? || params[:set_filter] || session[the_query[:key]].nil? || session[the_query[:key]][:project_id] != (@project ? @project.id : nil)
            # Give it a name, required to be valid
            @query = the_query[:klass].new(:name => "_")
            @query.project = @project
            if @query.is_a?Testit::TestitQuery
                @query.build_available_filters_for_project
            end
            @query.build_from_params(params)

            session[the_query[:key]] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names, :totalable_names => @query.totalable_names}
        else
            # retrieve from session
            @query = nil
            @query = the_query[:klass].find_by_id(session[the_query[:key]][:id]) if session[the_query[:key]][:id]
            @query ||= the_query[:klass].new(:name => "_", :filters => session[the_query[:key]][:filters], 
                                             :group_by => session[the_query[:key]][:group_by], 
                                             :column_names => session[the_query[:key]][:column_names], 
                                             :totalable_names => session[the_query[:key]][:totalable_names])
            @query.project = @project
            if @query.is_a?Testit::TestitQuery
                @query.build_available_filters_for_project
            end
        end
    end

    def retrieve_query_from_session
        if session[the_query[:key]]
            if session[the_query[:key]][:id]
                @query = the_query[:klass].find_by_id(session[the_query[:key]][:id])
                return unless @query
            else
                @query = the_query[:klass].new(:name => "_", :filters => session[the_query[:key]][:filters], 
                                               :group_by => session[the_query[:key]][:group_by], 
                                               :column_names => session[the_query[:key]][:column_names], 
                                               :totalable_names => session[the_query[:key]][:totalable_names])
            end
            if session[the_query[:key]].has_key?(:project_id)
                @query.project_id = session[the_query[:key]][:project_id]
            else
                @query.project = @project
            end
            if @query.is_a?Testit::TestitQuery
                @query.build_available_filters_for_project
            end
            @query
        end
    end


end
