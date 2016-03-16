class TestitSuitesController < ApplicationController
  unloadable

  before_filter :find_project, :authorize
  before_filter :find_issue, :only => [:show, :edit, :update]

  helper :projects
  helper :custom_fields
  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :repositories
  helper :sort
  helper :timelog
  helper :issues
  helper :testit_queries

  include TestitIssuesHelper


  # GET display a list of all events
  # /photos

  def index
      super
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
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
      flash[:notice] = l(:notice_test_case_created)
      redirect_to :controller=> :testit, :action => :index, :project_id => @project
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
          redirect_to :controller=> :testit, :action => :index, :project_id => @project
      else
          redirect_to :action => :edit, :project_id => @project
      end
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
  end


end

