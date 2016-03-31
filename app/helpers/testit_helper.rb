require 'application_helper'

module TestitHelper

    def get_testit_tabs(project)
        can_edit = User.current.allowed_to?(:edit_test_cases, project)
        can_execute = User.current.allowed_to?(:execute_test_cases, project)
        can_view = User.current.allowed_to?(:view_test_cases, project)
        # TODO 
        dev=true
        tabs = []
        if dev
            tabs << {
                :name => 'TestItIssues',
                :partial => 'testit_issues/index',
                :url => { :controller => :testit_issues, :action => :index},
                :label => :title_testit_issues
            }
        end
        tabs << {
            :name => 'TestItTests',
            :partial => 'testit_tests/index',
            :url => { :controller => :testit_tests, :action => :index},
            :label => :title_testit_tests
        } 
        tabs << {
            :name => 'TestItPlans',
            :partial => 'testit_plans/index',
            :url => { :controller => :testit_plans, :action => :index},
            :label => :title_testit_plans
        } # if can_view
        tabs << {
            :name => 'TestItRuns',
            :url => { :controller => :testit_runs, :action => :index},
            :partial => 'testit_runs/index',
            :label => :title_testit_runs
        } # if can_view
        # TODO
        # tabs << {
        #     :name => 'TestItReports',
        #     :partial => 'testit_reports/index',
        #     :url => { :controller => :testit_reports, :action => :index},
        #     :label => :title_testit_reports
        # } # if can_view
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
        s =  link_to_function(text, "showIssue('#{url_for_testit_issue(:issue_id => issue.id, :tracker_id => issue.tracker_id, :action => 'show')}');",  :class => issue.css_classes, :title => title)
        #     s = link_to(text, issue_url(issue, :only_path => only_path),:class => issue.css_classes, :title => title)
        s << h(": #{subject}") if subject
        s = h("#{issue.project} - ") + s if options[:project]
        s
    end

    #
    def url_for_testit_issue(options={})
        @project ||= Project.find(issue.project)
        @setting ||= find_setting
        tt = @setting.tracker_id_to_type( options[:tracker_id])
        ctrl = 'xx'
        case tt
        when Testit::Setting::BugTrackerType
            ctrl = 'testit_issues'
        when Testit::Setting::RequirementTrackerType
            ctrl = 'testit_issues'
        when Testit::Setting::TestCaseTrackerType
            ctrl = 'testit_tests'
        when Testit::Setting::TestSuiteTrackerType
            if options[:action] == 'index'
                ctrl = 'testit_tests'
            else
                ctrl = 'testit_suites'
            end
        when Testit::Setting::TestPlanTrackerType
            ctrl = 'testit_plans'
        when Testit::Setting::TestRunTrackerType
            ctrl = 'testit_runs'
        else
            ctrl = 'testit_issues'
        end

        x={ :controller => ctrl, :action => options[:action], :project_id => @project, :id => options[:issue_id]}
        x.merge(options[:params]) if options[:params]
        url_for(x)
    end

    def find_issues
        @issues = Issue.find(params[:ids])
    rescue ActiveRecord::RecordNotFound
        render_404
    end
    
    def find_issue
        @issue = Issue.find(params[:id])
        @project = @issue.project
    rescue ActiveRecord::RecordNotFound
        render_404
    end

    def find_project
        begin
            @project = Project.find(params[:project_id])
        rescue ActiveRecord::RecordNotFound
            render_404
        end
    end

    def find_setting
        begin
            @setting = Testit::Setting.find_by(:project_id => @project)
        rescue ActiveRecord::RecordNotFound
            render_404
        end
    end



end
