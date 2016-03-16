module Testit
  class RunsQuery < TestitQuery
      def build_available_filters_for_project
          build_trackers_filters_for(Testit::Setting::TestCaseTrackerType,
                                     Testit::Setting::TestRunTrackerType,
                                     Testit::Setting::TestPlanTrackerType)
      end
  end
end
