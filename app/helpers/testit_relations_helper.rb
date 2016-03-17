module TestitRelationsHelper
    def partial_query_common_options(options={})
        { :controller => 'testit_tests', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false }.merge(options)
    end
    def collection_for_testit_relation_type_select
        values = Testit::Relation::TYPES
        values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
    end
    def url_for_show_testit_issue(issue=nil)
        url_for( :controller => 'testit_issues', :action => 'show', :project_id => @project, :id => issue )
    end
end

