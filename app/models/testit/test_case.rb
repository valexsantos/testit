module Testit
  class TestCase  < Issue

    belongs_to :test_suite
    belongs_to :test_case

    def self.tracker(project)
        settings = Testit::Setting.find(project)
        Tracker.find(settings.test_case_tracker)
    end

  end
end
