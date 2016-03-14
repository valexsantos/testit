module TestitRelationsHelper
    def collection_for_testit_relation_type_select
        values = Testit::Relation::TYPES
        values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
    end
end

