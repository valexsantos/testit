require 'application_helper'

module TestitHelper

    def get_testit_tabs(project)
        can_edit = User.current.allowed_to?(:edit_test_cases, project)
        can_execute = User.current.allowed_to?(:execute_test_cases, project)
        can_view = User.current.allowed_to?(:view_test_cases, project)
        tabs = []
        tabs << {
            :name => 'TestIt::TestCase',
            :partial => 'testit_test_cases/index',
            :url => { :controller => :testit_test_cases, :action => :index},
            :label => :title_testit_tests
        } 
        tabs << {
            :name => 'TestIt::TestPlans',
            :partial => 'testit_test_plans/index',
            :url => { :controller => :testit_test_plans, :action => :index},
            :label => :title_testit_plans
        } # if can_view
        tabs << {
            :name => 'TestIt::TestRuns',
            :url => { :controller => :testit_test_runs, :action => :index},
            :partial => 'testit_test_runs/index',
            :label => :title_testit_executions
        } # if can_view
        tabs << {
            :name => 'TestIt::Reports',
            :partial => 'testit_reports/index',
            :url => { :controller => :testit_reports, :action => :index},
            :label => :title_testit_reports
        } # if can_view
        tabs
    end

end
