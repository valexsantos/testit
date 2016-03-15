module Testit
    class Relation < ActiveRecord::Base
        # reqs
        TYPE_TESTS         = "tests"         # test case testing the requirement
        TYPE_TESTED_BY     = "tested_by"     # requirement tested by
        # test_run / test_case
        TYPE_PART_OF_TC    = "part_of_tc"    # test run for test case
        TYPE_HAS_TR        = "has_tr"        # test case has test run
        # test_suite / test_case, test_plan / test_case
        TYPE_PART_OF_TS    = "part_of_ts"    # test case is part of this test suite
        TYPE_HAS_TC        = "has_tc"        # test plan / test suite has this test case
        TYPE_PART_OF_TP    = "part_of_tp"    # test case is part of this test plan

        #
        #   label_tests: "Tests"
        #   label_tested_by: "Tested by"
        #   label_for_test_case : "For test case"
        #   label_test_run : "Test execution"
        #   label_part_of_test_suite : "Part of test suite"
        #   label_has_test_case : "Has test case"
        #   label_part_of_test_plan : "Part of test plan"
        #
        TYPES = {
            TYPE_TESTS     => { :name => :label_tests, :sym_name => :label_tested_by, :order => 1, :sym => TYPE_TESTS, :reverse => TYPE_TESTED_BY },
            TYPE_TESTED_BY => { :name => :label_tested_by, :sym_name => :label_tests, :order => 2, :sym => TYPE_TESTED_BY, :reverse => TYPE_TESTS },
            #
            TYPE_PART_OF_TC => { :name => :label_part_of_test_case, :sym_name => :lable_has_test_run, :order => 3, :sym => TYPE_PART_OF_TC, :reverse => TYPE_HAS_TR},
            TYPE_HAS_TR     => { :name => :label_has_test_run, :sym_name => :lable_part_of_test_case, :order => 4, :sym => TYPE_HAS_TR, :reverse => TYPE_PART_OF_TC},
            #
            TYPE_PART_OF_TS => { :name => :label_part_of_test_suite, :sym_name => :label_has_test_case, :order => 5, :sym => TYPE_PART_OF_TS, :reverse => TYPE_HAS_TC},
            TYPE_HAS_TC     => { :name => :label_has_test_case, :sym_name => :label_part_of_test_suite, :order => 6, :sym => TYPE_HAS_TC, :reverse => TYPE_PART_OF_TS},
            TYPE_PART_OF_TP => { :name => :label_part_of_test_plan,  :sym_name => :label_has_test_case, :order => 7, :sym => TYPE_PART_OF_TP, :reverse => TYPE_HAS_TC}
        }
        # Class used to represent the relations of an issue
        class Relations < Array
            include Redmine::I18n

            def initialize(issue, *args)
                @issue = issue
                super(*args)
            end

            def to_s(*args)
                map {|relation| relation.to_s(@issue)}.join(', ')
            end
        end


        belongs_to :issue_from, :class_name => 'Issue'
        belongs_to :issue_to, :class_name => 'Issue'

        validates_presence_of :issue_from, :issue_to, :relation_type
        validates_inclusion_of :relation_type, :in => TYPES.keys
        validates_numericality_of :delay, :allow_nil => true
        validates_uniqueness_of :issue_to_id, :scope => :issue_from_id
        validate :validate_issue_relation

        attr_protected :issue_from_id, :issue_to_id
        before_save :handle_issue_order

        self.table_name = "testit_relations"

        def visible?(user=User.current)
            (issue_from.nil? || issue_from.visible?(user)) && (issue_to.nil? || issue_to.visible?(user))
        end

        def deletable?(user=User.current)
            visible?(user) &&
                ((issue_from.nil? || user.allowed_to?(:manage_issue_relations, issue_from.project)) ||
                 (issue_to.nil? || user.allowed_to?(:manage_issue_relations, issue_to.project)))
        end

        def initialize(attributes=nil, *args)
            super
            if new_record?
                if relation_type.blank?
                    self.relation_type = Relation::TYPE_TESTS
                end
            end
        end

        def validate_issue_relation
            #TODO
            if issue_from && issue_to
                errors.add :issue_to_id, :invalid if issue_from_id == issue_to_id
                unless issue_from.project_id == issue_to.project_id ||
                    Setting.cross_project_issue_relations?
                    errors.add :issue_to_id, :not_same_project
                end
                # detect circular dependencies depending wether the relation should be reversed
                if TYPES.has_key?(relation_type) && TYPES[relation_type][:reverse]
                    errors.add :base, :circular_dependency if issue_from.all_dependent_issues.include? issue_to
                else
                    errors.add :base, :circular_dependency if issue_to.all_dependent_issues.include? issue_from
                end
                if issue_from.is_descendant_of?(issue_to) || issue_from.is_ancestor_of?(issue_to)
                    errors.add :base, :cant_link_an_issue_with_a_descendant
                end
            end
        end

        def other_issue(issue)
            (self.issue_from_id == issue.id) ? issue_to : issue_from
        end

        # Returns the relation type for +issue+
        def relation_type_for(issue)
            if TYPES[relation_type]
                if self.issue_from_id == issue.id
                    relation_type
                else
                    TYPES[relation_type][:sym]
                end
            end
        end

        def label_for(issue)
            TYPES[relation_type] ?
                TYPES[relation_type][(self.issue_from_id == issue.id) ? :name : :sym_name] :
                :unknow
        end

        def to_s(issue=nil)
            issue ||= issue_from
            issue_text = block_given? ? yield(other_issue(issue)) : "##{other_issue(issue).try(:id)}"
            s = []
            s << l(label_for(issue))
            s << "(#{l('datetime.distance_in_words.x_days', :count => delay)})" if delay && delay != 0
            s << issue_text
            s.join(' ')
        end

        def css_classes_for(issue)
            "rel-#{relation_type_for(issue)}"
        end

        def handle_issue_order
            reverse_if_needed
            self.delay = nil
        end

        def <=>(relation)
            r = TYPES[self.relation_type][:order] <=> TYPES[relation.relation_type][:order]
            r == 0 ? id <=> relation.id : r
        end

        def init_journals(user)
            issue_from.init_journal(user) if issue_from
            issue_to.init_journal(user) if issue_to
        end

        def relations_for(issue)
            x=[]
            return unless issue

            testit_settings=  Testit::Setting.find_by(:project_id => issue.project)
            if testit_settings
                a=nil
                Testit::Setting::TrackersType.each { | tt |
                    trc = testit_settings.tracker(tt)
                    if trc.is_a?(Array)
                        a=tt if trc.include?(issue.tracker)
                    else
                        a=tt if trc == issue.tracker
                    end
                    break if a
                }
                if a
                    case a
                    when Testit::Setting::RequirementTrackerType
                        x = [ TYPE_TESTED_BY]
                    when Testit::Setting::TestCaseTrackerType
                        x = [ TYPE_TESTS, TYPE_HAS_TR, TYPE_PART_OF_TS, TYPE_PART_OF_TP]
                    when Testit::Setting::TestSuiteTrackerType
                        x = [ TYPE_HAS_TC ]
                    when Testit::Setting::TestPlanTrackerType
                        x = [ TYPE_HAS_TC ]
                    when Testit::Setting::TestRunTrackerType
                        x = [ TYPE_PART_OF_TC ]
                    end
                end
            end
            x.to_json
        end

        private

        def reverse_if_needed
            if TYPES.has_key?(relation_type) && TYPES[relation_type][:reverse]
                issue_tmp = issue_to
                self.issue_to = issue_from
                self.issue_from = issue_tmp
                self.relation_type = TYPES[relation_type][:reverse]
            end
        end
    end
end

