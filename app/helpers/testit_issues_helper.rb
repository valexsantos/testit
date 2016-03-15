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
                url_for(:controller => 'testit_test_cases', :action => 'new', :format => 'js') #:test_case=>issue
            else
                # new_issue_path(options)
                url_for(:controller => 'testit_test_cases', :action => 'new', :format => 'js') #:test_case=>issue
            end
        else
            url_for(:controller => 'testit_test_cases', :action => 'edit', :format => 'js')
            # edit__path(issue, options)
        end
    end
#   def render_descendants_tree(issue)
#     s = '<form><table class="list issues">'
#     issue_list(issue.descendants.visible.preload(:status, :priority, :tracker).sort_by(&:lft)) do |child, level|
#       css = "issue issue-#{child.id} hascontextmenu"
#       css << " idnt idnt-#{level}" if level > 0
#       s << content_tag('tr',
#              content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
#              content_tag('td', link_to_issue(child, :project => (issue.project_id != child.project_id)), :class => 'subject', :style => 'width: 50%') +
#              content_tag('td', h(child.status)) +
#              content_tag('td', link_to_user(child.assigned_to)) +
#              content_tag('td', progress_bar(child.done_ratio)),
#              :class => css)
#     end
#     s << '</table></form>'
#     s.html_safe
#   end


end

