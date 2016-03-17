class TestitRelationsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize
  before_filter :find_issue
  before_filter :find_setting

  helper :testit_sort
  helper :testit_queries

  #
  include TestitSortHelper
  include TestitQueriesHelper
  #
  # GET display a list of all events
  # /photos
  def index
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end
  # GET display a specific event
  # /photos/:id
  def show
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      respond_to do | format | 
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/show.hook' }
      end
  end

  #
  # testit relations
  # as views sao uma lista para piq piq piq
  #
  # GET return an HTML form for creating a new event
  # /photos/new
  # add test_suite relation to test_case
  def new_ts
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      retrieve_query_for(Testit::Setting::TestSuiteTrackerType)

      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_to_test_suite)} }
      end
  end
  # add test_run relation to test_case
  def new_tr
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      retrieve_query_for(Testit::Setting::TestRunTrackerType)

      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_test_run)} }
      end
  end
  # add test_csse relation to test_plan / test_suite
  def new_tc
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      retrieve_query_for(Testit::Setting::TestCaseTrackerType)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_test_case)} }
      end
  end
  # add test_plan relation to test_case
  def new_tp
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      retrieve_query_for(Testit::Setting::TestPlanTrackerType)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_to_test_plan)} }
      end
  end
  # add reuirement relation to test_case
  def new_req
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new
      retrieve_query_for(Testit::Setting::RequirementTrackerType)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_requirement)} }
      end
  end

  # GET return an HTML form for editing an event
  # /photos/:id/edit
  def edit
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end

  # POST create a new event
  # /photos
  def create
  end
  # PUT update a specific event
  # /photos/:id
  def update
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
  end


  def find_project
      begin
          @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end

  def find_setting
      begin
          @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end
  def retrieve_query_for(*testit_tracker_types)
      @query = Testit::TestitQuery.new(:name => "_")
      @query.project = @project
      @query.build_trackers_filters_for(*testit_tracker_types)
      @query.build_from_params(params)
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      if @query.valid?
          @limit = per_page_option
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

end

