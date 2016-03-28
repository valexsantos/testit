class TestitSuitesController < ApplicationController
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
  helper :watchers
  helper :attachments
  helper :repositories
  helper :timelog
  helper :issue_relations
  #
  helper :testit
  helper :testit_sort
  helper :testit_queries
  helper :testit_issues
  helper :testit_relations
  helper :testit_suites

  include TestitIssuesAbstractController

  include TestitSuitesHelper
  include TestitHelper

  # GET display a specific event
  # /photos/:id
  def show
      super
      respond_to do | format |
          format.html {
            retrieve_previous_and_next_issue_ids
            render :layout => !request.xhr?
          }
          format.pdf  {
              send_file_headers! :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf"
          }

      end
  end

  # GET return an HTML form for creating a new event
  # /photos/new
  def new
      super
      @tracker = @setting.tracker(Testit::Setting::TestSuiteTrackerType)
      respond_to do | format |
          format.html { render :layout => !request.xhr? }
          format.js
      end
  end

  # GET return an HTML form for editing an event
  # /photos/:id/edit
  def edit
      super
      respond_to do | format |
          format.html { render :layout => !request.xhr? }
          format.js
      end
  end

  # POST create a new event
  # /photos
  def create
      if super
          # TODO flash[:notice] = l(:notice_test_case_created)
          redirect_to  :controller => :testit_tests, :action => :show, :project_id => @project, :id => @issue
      else
          # TODO flash[:error] = l(:failed_to_create)
          redirect_to :action => :new, :project_id => @project
      end
  end
  # PUT update a specific event
  # /photos/:id
  def update
      if super
          render_attachment_warning_if_needed(@issue)
          # TODO flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          redirect_to  :controller => :testit_tests, :action => :show, :project_id => @project, :id => @issue
      else
          redirect_to :action => :edit, :project_id => @project
      end
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
  end


end

