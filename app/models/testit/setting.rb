module Testit
  class Setting < ActiveRecord::Base
    unloadable
    self.table_name = "testit_settings"

    attr_accessible :project_id, :bug_tracker, :requirement_tracker, :test_case_tracker,
        :test_suite_tracker, :test_plan_tracker, :test_run_tracker

    serialize :requirement_tracker

    def can_manage_requirements?
      requirement_tracker && requirement_tracker.any? {|e| e != "" }
    end
  end
end
