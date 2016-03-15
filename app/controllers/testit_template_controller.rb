class TestitTemplatesController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  # GET display a list of all events
  # /photos
  def index
      # TODO FIX - Retirar as inicializacoes dos settings
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

