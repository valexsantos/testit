module Testit
    class Hooks < Redmine::Hook::ViewListener
        render_on :view_issues_show_description_bottom,
            :partial => 'testit_relations/show.test'

        def view_issues_show_description_bottom(context={ })
            # the controller parameter is part of the current params object
            # This will render the partial into a string and return it.

            issue = context[:issue]
            return unless issue && issue.project 

            context[:controller].send(:render_to_string, {
                :partial => "testit_relations/show.hook",
                :locals => context.merge( :@settings => Testit::Setting.find_by(:project_id => issue.project))
            })
        end

    end
end

