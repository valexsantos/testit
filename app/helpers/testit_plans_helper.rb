require 'application_helper'

module TestitPlansHelper
    def partial_query_common_options
        { :controller => 'testit_plans', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false }
    end

end

