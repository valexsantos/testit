module Testit
  class TestPlan 

    def self.tracker(project)
        settings = Testit::Setting.find(project)
        Tracker.find(settings.test_plan_tracker)
    end

  end
end
