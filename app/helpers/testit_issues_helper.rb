require 'application_helper'

module TestitIssuesHelper
    include IssuesHelper
    include TestitHelper

    # Returns the path for updating the issue form
    # with project as the current project
    def update_issue_form_path(project, issue)
        options = {:format => 'js'}
        if issue.new_record?
            if project
                # new_project_issue_path(project, options)
                url_for(:controller => 'testit_issues', :action => 'new', :format => 'js') #:test_case=>issue
            else
                # new_issue_path(options)
                url_for(:controller => 'testit_issues', :action => 'new', :format => 'js') #:test_case=>issue
            end
        else
            url_for(:controller => 'testit_issues', :action => 'edit', :format => 'js')
            # edit__path(issue, options)
        end
    end

end

