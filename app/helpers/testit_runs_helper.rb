require 'application_helper'

module TestitRunsHelper

    include TestitQueriesHelper

    def partial_query_common_options(options={})
        { :controller => 'testit_runs', :action => 'index', :project_id => @project,
                         :table=>true, :modal=> true, :layout => false }.merge(options)
    end
    #
    # requires testit_x_helper... ahahah
    #
##    def column_value(column, issue, value)
##        case column.name
##        when :id
##            link_to_function issue.id, "showIssue('#{url_for(:id => issue.id, :tracker_id => issue.tracker_id, :action => 'show', :controller => 'testit_runs')}');"
##        when :subject
##            link_to_function issue.subject, "showIssue('#{url_for(:id => issue.id, :tracker_id => issue.tracker_id, :action => 'show', :action => 'show', :controller => 'testit_runs')}');"
##        else
##            super
##        end
##    end

end

