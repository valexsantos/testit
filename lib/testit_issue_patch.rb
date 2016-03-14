module TestitIssuePatch

    def self.included(base)
        base.class_eval do
            has_many :testit_relations_from, :class_name => 'Testit::Relation', :foreign_key => 'issue_from_id', :dependent => :delete_all
            has_many :testit_relations_to, :class_name => 'Testit::Relation', :foreign_key => 'issue_to_id', :dependent => :delete_all

        end
        base.send(:include, TestitRelations)
    end
end


module TestitRelations

    def testit_relations
        @testit_relations ||= Testit::Relation::Relations.new(self, (testit_relations_from + testit_relations_to).sort)
    end

end

