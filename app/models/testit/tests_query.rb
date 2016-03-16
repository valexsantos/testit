module Testit
  class TestsQuery < TestitQuery
      def build_available_filters_for_project
          build_trackers_filters_for(Testit::Setting::TestCaseTrackerType,
                                     Testit::Setting::TestSuiteTrackerType)
      end
  end
end
