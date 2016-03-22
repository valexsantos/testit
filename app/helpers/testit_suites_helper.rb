require 'application_helper'

module TestitSuitesHelper
    
    def partial_query_common_options(options={})
        { :controller => 'testit_suites', :action => 'list', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false }.merge(options)
    end
    
end

