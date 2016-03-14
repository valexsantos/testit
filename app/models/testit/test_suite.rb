module Testit
  class TestSuite
    def self.tracker(project)
        settings = Testit::Setting.find(project)
        Tracker.find(settings.test_suite_tracker)
    end
  end
end
