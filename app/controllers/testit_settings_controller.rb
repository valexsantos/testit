class TestitSettingsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
  end

  def edit
      # TODO FIX Remover estaas inicializacoes do settings
    @setting = Testit::Setting.find_or_initialize_by(:project_id => @project.id)
    unless params[:setting][:requirement_tracker]
      params[:setting][:requirement_tracker] = []
    end
    @setting.update_attributes(params[:setting])
    if request.put? or request.post? or request.patch?
      ActiveRecord::Base.transaction do
        @setting.save!
        flash[:notice] = l(:notice_successful_update)
        redirect_to settings_project_path(@project, :tab => 'testit')
      end
    end
  end


  def find_project
      begin
          @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end

end
