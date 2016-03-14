require 'application_helper'

module TestitSortHelper
    include SortHelper


    def sort_link(column, caption, default_order)
        css, order = nil, default_order

        if column.to_s == @sort_criteria.first_key
            if @sort_criteria.first_asc?
                css = 'sort asc'
                order = 'desc'
            else
                css = 'sort desc'
                order = 'asc'
            end
        end
        caption = column.to_s.humanize unless caption

        sort_options = { :sort => @sort_criteria.add(column.to_s, order).to_param }
        url_options = params.merge(sort_options)

        # Add project_id to url_options
        url_options = url_options.merge(:project_id => params[:project_id]) if params.has_key?(:project_id)
        url_options = url_options.merge(:table => true)
        link_to_function(h(caption), "sortColumn(this,'#{url_for url_options}')", :class => css)
#        link_to_content_update(h(caption), url_options, :class => css)
    end
                                         

end

