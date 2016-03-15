require 'application_helper'

module TestitHelper

    def get_testit_tabs(project)
        can_edit = User.current.allowed_to?(:edit_test_cases, project)
        can_execute = User.current.allowed_to?(:execute_test_cases, project)
        can_view = User.current.allowed_to?(:view_test_cases, project)
        tabs = []
        tabs << {
            :name => 'TestItTestCase',
            :partial => 'testit_test_cases/index',
            :url => { :controller => :testit_test_cases, :action => :index},
            :label => :title_testit_tests
        } 
        tabs << {
            :name => 'TestItTestPlans',
            :partial => 'testit_test_plans/index',
            :url => { :controller => :testit_test_plans, :action => :index},
            :label => :title_testit_plans
        } # if can_view
        tabs << {
            :name => 'TestItTestRuns',
            :url => { :controller => :testit_test_runs, :action => :index},
            :partial => 'testit_test_runs/index',
            :label => :title_testit_executions
        } # if can_view
        tabs << {
            :name => 'TestItReports',
            :partial => 'testit_reports/index',
            :url => { :controller => :testit_reports, :action => :index},
            :label => :title_testit_reports
        } # if can_view
        tabs
    end

  # Displays a link to +issue+ with its subject.
  # Examples:
  #
  #   link_to_issue(issue)                        # => Defect #6: This is the subject
  #   link_to_issue(issue, :truncate => 6)        # => Defect #6: This i...
  #   link_to_issue(issue, :subject => false)     # => Defect #6
  #   link_to_issue(issue, :project => true)      # => Foo - Defect #6
  #   link_to_issue(issue, :subject => false, :tracker => false)     # => #6
  #
  def link_to_issue(issue, options={})
    title = nil
    subject = nil
    text = options[:tracker] == false ? "##{issue.id}" : "#{issue.tracker} ##{issue.id}"
    if options[:subject] == false
      title = issue.subject.truncate(60)
    else
      subject = issue.subject
      if truncate_length = options[:truncate]
        subject = subject.truncate(truncate_length)
      end
    end
    only_path = options[:only_path].nil? ? true : options[:only_path]
    s =  link_to_function(text, "showIssue(#{issue.id});",  :class => issue.css_classes, :title => title)
#     s = link_to(text, issue_url(issue, :only_path => only_path),:class => issue.css_classes, :title => title)
    s << h(": #{subject}") if subject
    s = h("#{issue.project} - ") + s if options[:project]
    s
  end
end
