require 'application_helper'

module TestitIssuesPathHelper

    def url_for_show_testit_issue(issue=nil)
        if issue
        url_for( :controller => 'testit_issues', :action => 'show', :project_id => @project, :id => issue )
        else
        url_for( :controller => 'testit_issues', :action => 'show', :project_id => @project, :id => nil)
        end
    end
    def url_for_update_testit_issue
        url_for( :controller => 'testit_issues', :action => 'update', :project_id => @project )
    end
    def url_for_create_testit_issue
        url_for( :controller => 'testit_issues', :action => 'create', :project_id => @project )
    end
    def url_for_new_testit_issue
        url_for( :controller => 'testit_issues', :action => 'new', :project_id => @project )
    end

end

