module Testit
  class PlansQuery < TestitQuery
      def build_available_filters_for_project
          build_trackers_filters_for(Testit::Setting::TestPlanTrackerType)
      end
  end
end
