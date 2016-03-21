class TestitPlansController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :find_setting
  before_filter :find_issue, :only => [:show, :edit, :update]
  before_filter :find_issues, :only => [:destroy]
  before_filter :authorize, :except => [:index, :new, :create]

  before_filter :build_new_issue_from_params, :only => [:new, :create]

  helper :projects
  helper :custom_fields
  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :repositories
  helper :timelog
  #
  helper :testit
  helper :testit_sort
  helper :testit_queries
  helper :testit_issues
  helper :testit_plans

  include TestitIssuesAbstractController
  include TestitPlansHelper
  include TestitHelper

  def the_query
      {:key=>:plans_query, :klass => Testit::PlansQuery}
  end


  # GET display a list of all events
  # /photos
  def index
      super
      respond_to do | format | 
          if params[:table]
              # TODO FIX isto e' o reload da tabela 
              format.html { render :partial=> "testit_common/issue_list", :layout => !request.xhr?, 
                            :locals => {:query => @query, :issues => @issues,
                            :title => l(:label_test_plan_plural),
                            :available_formats => ['Atom', 'CSV', 'PDF'],
                            :query_form_id => 'query-form',
                            :query_submit_url => partial_query_common_options,
                            :query_list_dest_id => 'issue-list',
                            :table_form_id => 'table-issue-list',
                            :table_show_select_all => false}
              }
          else
              format.html { render :layout => !request.xhr? }
          end
      end
  end
  # GET display a specific event
  # /photos/:id
  def show
      super
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end

  # GET return an HTML form for creating a new event
  # /photos/new
  def new
      super
      @tracker = @setting.tracker(Testit::Setting::TestPlanTrackerType)
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end

  # GET return an HTML form for editing an event
  # /photos/:id/edit
  def edit
      super
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end

  # POST create a new event
  # /photos
  def create
      super
      flash[:notice] = l(:notice_test_plan_created)
      redirect_to  :action => :show, :project_id => @project, :id => @issue
  rescue 
      flash[:error] = $!.message
      redirect_to :action => :new, :project_id => @project
  end
  # PUT update a specific event
  # /photos/:id
  def update
      if super
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          redirect_to  :action => :show, :project_id => @project, :id => @issue
      else
          redirect_to :action => :edit, :project_id => @project
      end
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
  end


end

