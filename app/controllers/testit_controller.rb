class TestitController < ApplicationController
  unloadable

  menu_item :testit
  before_filter :find_project, :authorize

  def index
    @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)
    p @setting
  end


  def find_project
      begin
          @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end


end

