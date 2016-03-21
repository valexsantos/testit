module Testit
    class Relation < ActiveRecord::Base
        #
        TYPE_REQ_HAS_TC     = "req_has_tc"
        TYPE_TC_PART_OF_REQ = "tc_part_of_req"
        TYPE_TC_HAS_TR      = "tc_has_tr"
        TYPE_TR_PART_OF_TC  = "tr_part_of_tc"
        TYPE_TP_HAS_TC      = "tp_has_tc"
        TYPE_TC_PART_OF_TP  = "tc_part_of_tp"
        TYPE_TS_HAS_TC      = "ts_has_tc"
        TYPE_TC_PART_OF_TS  = "tc_part_of_ts"

        TYPES = {
            TYPE_REQ_HAS_TC     => { :name => :label_req_has_tc, :sym_name => :label_tc_part_of_req, :order => 1, :sym => TYPE_REQ_HAS_TC, :reverse => TYPE_TC_PART_OF_REQ},
            TYPE_TC_PART_OF_REQ => { :name => :label_tc_part_of_req, :sym_name => :label_req_has_tc, :order => 2, :sym => TYPE_TC_PART_OF_REQ, :reverse => TYPE_REQ_HAS_TC},

            TYPE_TC_HAS_TR      => {:name => :lable_tc_has_tr, :sym_name => :lable_tr_part_of_tc, :order => 3, :sym => TYPE_TC_HAS_TR ,:reverse => TYPE_TR_PART_OF_TC },
            TYPE_TR_PART_OF_TC  => {:name => :lable_tr_part_of_tc, :sym_name => :lable_tc_has_tr, :order => 4, :sym => TYPE_TR_PART_OF_TC ,:reverse => TYPE_TC_HAS_TR },

            TYPE_TP_HAS_TC      => {:name => :lable_tp_has_tc, :sym_name => :lable_tc_part_of_tp, :order => 5, :sym => TYPE_TP_HAS_TC ,:reverse => TYPE_TC_PART_OF_TP },
            TYPE_TC_PART_OF_TP  => {:name => :lable_tc_part_of_tp, :sym_name => :lable_tp_has_tc, :order => 6, :sym => TYPE_TC_PART_OF_TP ,:reverse => TYPE_TP_HAS_TC },
            
            TYPE_TS_HAS_TC      => {:name => :lable_ts_has_tc, :sym_name => :lable_tc_part_of_ts, :order => 7, :sym => TYPE_TS_HAS_TC ,:reverse => TYPE_TC_PART_OF_TS },
            TYPE_TC_PART_OF_TS  => {:name => :lable_tc_part_of_ts, :sym_name => :lable_ts_has_tc, :order => 8, :sym => TYPE_TC_PART_OF_TS ,:reverse => TYPE_TS_HAS_TC },
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

            # filter relation type
            # e.g. 
            # where(:relation_type => 'req_has_tc')
            def where(options={})
               map{|relation| relation if relation 
                   x = true
                   options.each { | k,v | 
                       x = x && relation.send(k) == v
                       break if !x
                   }
                   relation if x
               }
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
                    self.relation_type = Relation::TYPE_REQ_HAS_TC
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

