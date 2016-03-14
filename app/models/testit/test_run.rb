module Testit
  class TestRun
    def self.tracker(project)
        settings = Testit::Setting.find(project)
        Tracker.find(settings.test_run_tracker)
    end

  end
end
