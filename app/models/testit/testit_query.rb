module Testit
  class TestitQuery < IssueQuery

      def initialize(attributes=nil, *args)
          super
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
          p " ################## [#{qfs}]"
          @project_filter_statement = qfs
      end
      def statement
          x=super
          x<<@project_filter_statement
          x
      end
  end
end
