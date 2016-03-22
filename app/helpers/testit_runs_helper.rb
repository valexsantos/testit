require 'application_helper'

module TestitRunsHelper

    def partial_query_common_options(options={})
        { :controller => 'testit_runs', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false }.merge(options)
    end

end

