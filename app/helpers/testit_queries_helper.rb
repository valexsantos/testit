require 'application_helper'

module TestitQueriesHelper
    include QueriesHelper

    def column_value(column, issue, value)
        case column.name
        when :id
            link_to_function issue.id, "showIssue(#{issue.id});"
        when :subject
            link_to_function issue.subject, "showIssue(#{issue.id});"
        else
            super
        end
    end

end
