class TestitRelationsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize
  before_filter :find_issue

  helper :testit_sort
  helper :testit_queries

  #
  include TestitSortHelper
  include TestitQueriesHelper
  #
  # GET display a list of all events
  # /photos
  def index
      @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end
  # GET display a specific event
  # /photos/:id
  def show
  end

  # GET return an HTML form for creating a new event
  # /photos/new
  def new
      @relation = IssueRelation.new
      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @testit_relation = Testit::Relation.new


      retrieve_query
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





      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
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


end

