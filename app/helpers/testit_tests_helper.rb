require 'application_helper'

module TestitTestsHelper

    def partial_query_common_options(options={})
        { :controller => 'testit_tests', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false, :coisas => true }.merge(options)
    end
end

