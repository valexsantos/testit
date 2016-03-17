class TestitRunsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
      # TODO FIX - Remover estas inicializacoes
    @setting = Testit::Setting.find_by(:project_id => @project) || Testit::Setting.create(:project_id => @project.id)
      respond_to do | format |
          if params[:table]
              # TODO FIX isto e' o reload da tabela 
              format.html { render :partial=> "testit_common/issue_list", :layout => !request.xhr?, 
                            :locals => {:query => @query, :issues => @issues,
                            :title => l(:label_test_execution_plural),
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


  def find_project
      begin
          @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end


end

