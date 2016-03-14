class SetupTestitTrackers < ActiveRecord::Migration

    def self.up
        # TestCase
        # TestSuite
        # TestPlan
        #   status
        #     Ready
        #     Obsoleted
        new_status=IssueStatus.where(
            :name => "New",
            :is_closed => false
        ).first_or_create
        in_progress_status = IssueStatus.where(
            :name => "In Progress",
            :is_closed => false
        ).first_or_create
        ready_status=IssueStatus.where(
            :name => "Ready",
            :is_closed => false
        ).first_or_create
        obsoleted_status = IssueStatus.where(
            :name => "Obsoleted",
            :is_closed => false
        ).first_or_create
        rejected_status = IssueStatus.where(
            :name => "Rejected",
            :is_closed => true
        ).first_or_create
        closed_status = IssueStatus.where(
            :name => "Closed",
            :is_closed => true
        ).first_or_create
        # TestExecution
        #   status:
        #     Passed
        #     Failed
        #     Blocked
        #     Not available
        passed_status = IssueStatus.where(
            :name => "Passed",
            :is_closed => false
        ).first_or_create
        failed_status = IssueStatus.where(
            :name => "Failed",
            :is_closed => false
        ).first_or_create
        blocked_status = IssueStatus.where(
            :name => "Blocked",
            :is_closed => false
        ).first_or_create
        na_status = IssueStatus.where(
            :name => "Not available",
            :is_closed => false
        ).first_or_create
        # 
        testcase_tracker =  Tracker.where(
            :name => 'Test case',
            :default_status => new_status
        ).first_or_create
        testsuite_tracker =  Tracker.where(
            :name => 'Test suite',
            :default_status => new_status
        ).first_or_create
        testplan_tracker =  Tracker.where(
            :name => 'Test plan',
            :default_status => new_status
        ).first_or_create
        testexecution_tracker =  Tracker.where(
            :name => 'Test execution',
            :default_status => na_status
        ).first_or_create
        # workflow
        Role.all.each { |role|
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => ready_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => ready_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => ready_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => ready_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testcase_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => ready_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => ready_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => ready_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => ready_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testsuite_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => new_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => new_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => ready_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => in_progress_status, :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => ready_status,     :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => ready_status,     :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => ready_status,     :new_status => obsoleted_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => closed_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => in_progress_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => obsoleted_status, :new_status => rejected_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => closed_status,    :new_status => new_status)
            WorkflowTransition.create!(:tracker => testplan_tracker, :role => role , :old_status => rejected_status,  :new_status => new_status)
            #
            #
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :new_status => na_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => na_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => na_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => na_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => passed_status,  :new_status => na_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => passed_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => passed_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => failed_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => failed_status,  :new_status => na_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => failed_status,  :new_status => blocked_status)
            #
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => blocked_status,  :new_status => passed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => blocked_status,  :new_status => failed_status)
            WorkflowTransition.create!(:tracker => testexecution_tracker, :role => role , :old_status => blocked_status,  :new_status => na_status)
        }

    end

    def self.down
    end

end

