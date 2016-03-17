require 'application_helper'

module TestitTestsHelper

    def partial_query_common_options(options={})
        { :controller => 'testit_tests', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false, :coisas => true }.merge(options)
    end

    def url_for_show_testit_issue(issue=nil)
        url_for( :controller => 'testit_tests', :action => 'show', :project_id => @project, :id => issue )
    end
    def url_for_edit_testit_issue(issue=nil)
        url_for( :controller => 'testit_tests', :action => 'edit', :project_id => @project, :id => issue )
    end
    def url_for_update_testit_issue(issue=nil)
        url_for( :controller => 'testit_tests', :action => 'update', :project_id => @project, :id => issue )
    end
    def url_for_create_testit_issue(issue=nil)
        url_for( :controller => 'testit_tests', :action => 'create', :project_id => @project, :id => issue )
    end
    def url_for_new_testit_issue
        url_for( :controller => 'testit_tests', :action => 'new', :project_id => @project )
    end
end

