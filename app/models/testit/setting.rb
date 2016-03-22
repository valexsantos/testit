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
    TestRunTrackerType     = 'test_run_tracker'

    TrackersType = [ BugTrackerType, RequirementTrackerType, TestCaseTrackerType,
                     TestSuiteTrackerType, TestPlanTrackerType, TestRunTrackerType ]

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

    def issue_is_a?(testit_tracker_type, issue)
        tracker_id_is_a?(testit_tracker_type,issue.tracker_id)
    end

    def tracker_type_of(issue)
        tracker_id_to_type(issue.tracker_id)
    end
    # 
    # XXX FIX TODO
    #
    def tracker_id_to_type(tracker_id)
        TrackersType.each { | tt |
            return tt if tracker_id_is_a?(tt,tracker_id)
        }
        nil
    end
    def tracker_id_is_a?(testit_tracker_type, tracker_id)
        tk = self.send(testit_tracker_type)
        if tk.is_a?(Array)
            return tk.include?("#{tracker_id}")
        else
            return tracker_id == tk
        end
    end

  end

end

