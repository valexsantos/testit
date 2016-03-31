class SetupTestitTrackers < ActiveRecord::Migration


    def create_issue_status(opts={})
        stat = IssueStatus.where(opts).first
        if !stat
            pos = IssueStatus.all.size
            stat = IssueStatus.new(opts)
            stat.position = pos + 1
            stat.save
        end
        stat
    end
    def create_tracker(opts={})
        stat = Tracker.where(opts).first
        if !stat
            pos = Tracker.all.size
            stat = Tracker.new(opts)
            stat.position = pos +1
            stat.save
        end
        stat
    end
    def self.up
        # TestCase
        # TestSuite
        # TestPlan
        #   status
        #     Resolved
        #     Obsoleted
        new_status=create_issue_status(
            :name => "New",
            :is_closed => false
        )
        in_progress_status = create_issue_status(
            :name => "In Progress",
            :is_closed => false
        )
        resolved_status = create_issue_status(
            :name => "Resolved",
            :is_closed => false
        )
        obsoleted_status = create_issue_status(
            :name => "Obsoleted",
            :is_closed => false
        )
        rejected_status = create_issue_status(
            :name => "Rejected",
            :is_closed => true
        )
        closed_status = create_issue_status(
            :name => "Closed",
            :is_closed => true
        )
        # TestExecution
        #   status:
        #     Passed
        #     Failed
        #     Blocked
        #     Not available
        passed_status = create_issue_status(
            :name => "Passed",
            :is_closed => false
        )
        failed_status = create_issue_status(
            :name => "Failed",
            :is_closed => false
        )
        blocked_status = create_issue_status(
            :name => "Blocked",
            :is_closed => false
        )
        na_status = create_issue_status(
            :name => "Not available",
            :is_closed => false
        )
        # 
        #
        testcase_tracker = create_tracker(
            :name => 'Test case',
            :default_status => new_status
        )
        #
        testsuite_tracker = create_tracker(
            :name => 'Test suite',
            :default_status => new_status
        )
        #
        testplan_tracker = create_tracker(
            :name => 'Test plan',
            :default_status => new_status
        )
        #
        testrun_tracker = create_tracker(
            :name => 'Test run',
            :default_status => na_status
        )
        # workflow
        Role.all.each { |role|
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => resolved_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => resolved_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => resolved_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => resolved_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => resolved_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => resolved_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => resolved_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => resolved_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => resolved_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => resolved_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => resolved_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => resolved_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            #
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :new_status => na_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => na_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => na_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => na_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => passed_status,  :new_status => na_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => passed_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => passed_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => failed_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => failed_status,  :new_status => na_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => failed_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => blocked_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => blocked_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testrun_tracker, :role => role , :old_status => blocked_status,  :new_status => na_status)
        }

    end

    def self.down
    end

end

