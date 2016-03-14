class TestitTestRunsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
    @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)
      respond_to do | format |
          format.html { render :layout => !request.xhr? }
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

