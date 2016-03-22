module Testit
  class TestitQuery < IssueQuery

      def initialize(attributes=nil, *args)
          super
          @project_filter_statement=''
      end

      def build_available_filters_for_project
          # to implement on derived classes
      end
      def build_trackers_filters_for(*testit_trackers_types)
          settings = Testit::Setting.find_by(:project_id => project)
          values =[]
          qfs=" AND (issues.tracker_id IN ("
          testit_trackers_types.each{ | tt |
              trk = settings.tracker(tt)
              if trk.is_a?Array
                  values.concat(trk.collect{ |t|  [ t.name, t.id.to_s ]})
              else
                  values << [ trk.name, trk.id.to_s ]
              end
          }
          qfs << values.map{|v| "'#{v[1]}'"}.join(',')
          qfs<<'))'
          available_filters["tracker_id"] = {:type=>:list, :values=>values,  :name=>"Tracker"}
          @project_filter_statement = qfs
      end
      def append_to_filter_statement(qfs)
          @project_filter_statement << qfs
      end
      def statement
          x=super
          x<<@project_filter_statement
          x
      end


      # Returns the issues ids AND tracker_id
      def issue_ids(options={})
          order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

          Issue.visible.
              joins(:status, :project).
              where(statement).
              includes(([:status, :project] + (options[:include] || [])).uniq).
              references(([:status, :project] + (options[:include] || [])).uniq).
              where(options[:conditions]).
              order(order_option).
              joins(joins_for_order_statement(order_option.join(','))).
              limit(options[:limit]).
              offset(options[:offset]).
              pluck(:id,:tracker_id)
      rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
      end

  end
end
