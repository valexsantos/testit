require_dependency 'projects_helper'

# This patch adds TestIt linkages to Project
module TestitProjectsHelperPatch

    def self.included(base)
        base.send(:include, ProjectsHelperMethodsTestit)
        base.send(:include, TestitSettingsHelper)

        base.class_eval do
            alias_method_chain :project_settings_tabs, :testit
        end
    end

end


module ProjectsHelperMethodsTestit
    def project_settings_tabs_with_testit
        tabs = project_settings_tabs_without_testit
        action = {:name => 'testit', :controller => :testit_settings, :action => :show, :partial => 'testit_settings/show', :label => :project_module_testit}

        tabs << action if User.current.allowed_to?(action, @project)

        tabs
    end
end

