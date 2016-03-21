module Testit
  class RunsQuery < TestitQuery
      def build_available_filters_for_project
          build_trackers_filters_for(Testit::Setting::TestCaseTrackerType,
                                     Testit::Setting::TestSuiteTrackerType,
                                     Testit::Setting::TestRunTrackerType,
                                     Testit::Setting::TestPlanTrackerType)
          
          qfs=' AND (issues.id IN ('
          qfs<< "select id from issues where id not in ( select issue_from_id as id from (select issue_from_id from testit_relations where relation_type not in ('req_has_tc', 'tc_part_of_req','tr_part_of_tc','tc_has_tr')) id_from union select issue_to_id as id from (select issue_to_id from testit_relations where relation_type not in ('req_has_tc', 'tc_part_of_req','tr_part_of_tc','tc_has_tr')) id_to) or id in ( select issue_from_id as id from (select issue_from_id from testit_relations where relation_type not in ('req_has_tc', 'tc_part_of_req','tr_part_of_tc','tc_has_tr')) id_from union select issue_to_id as id from (select issue_to_id from testit_relations where relation_type not in ('req_has_tc', 'tc_part_of_req','tr_part_of_tc','tc_has_tr')) id_to) and tracker_id in (5,6)"
          qfs<<'))'
          append_to_filter_statement(qfs)
      end
  end
end
