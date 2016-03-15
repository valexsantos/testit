module Testit
  class Setting < ActiveRecord::Base
    unloadable
    self.table_name = "testit_settings"

    before_save :validate
    #
    BugTrackerType         = 'bug_tracker'
    RequirementTrackerType = 'requirement_tracker'
    TestCaseTrackerType    = 'test_case_tracker'
    TestSuiteTrackerType   = 'test_suite_tracker'
    TestPlanTrackerType    = 'test_plan_tracker'
    TestRunTrackerType     = 'test_plan_tracker'

    TrackersType = [ BugTrackerType, RequirementTrackerType, TestCaseTrackerType,
                     TestSuiteTrackerType, TestPlanTrackerType, TestRunTrackerType ]
    # TODO add some validations
    attr_accessible :project_id, :bug_tracker, :requirement_tracker, :test_case_tracker,
        :test_suite_tracker, :test_plan_tracker, :test_run_tracker

    serialize :requirement_tracker

    def can_manage_requirements?
      requirement_tracker && requirement_tracker.any? {|e| e != "" }
    end

    def initialized?
        TrackersType.each { | tt | 
            return false if !valid_tracker?(tt)
        }
        true
    rescue ActiveRecord::RecordNotFound
        # p $!, $!.backtrace
        false
    end

    def valid_tracker?(tracker_type)
        self.send(tracker_type) && (x = tracker(tracker_type) && x != [])
    rescue ActiveRecord::RecordNotFound
        false
    end

    # sanitize....
    def validate
        TrackersType.each { | tt |
            stt = self.send(tt)
            if stt && stt.is_a?(Array)
                stt.reject!(&:blank?)
                stt.uniq!
            end
            errors.add(tt.to_sym, "- mandatory field", strict: true) unless stt && valid_tracker?(tt)
        }
    end

    def tracker(testit_tracker_type) 
        Tracker.find(self.send(testit_tracker_type))
    end
  end

end

