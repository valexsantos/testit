require 'redmine'
require 'testit_projects_helper_patch'
require 'testit_issue_patch'

Rails.configuration.to_prepare do

     unless ProjectsHelper.included_modules.include? TestitProjectsHelperPatch
         ProjectsHelper.send(:include, TestitProjectsHelperPatch)
     end
     Issue.send :include, TestitIssuePatch
 
end

Redmine::Plugin.register :testit do
    name 'TestIt'
    author 'Vasco Santos'
    description 'Test management tool'
    version '0.0.1'
    url 'https://github.com/valexsantos/testit'
    author_url 'https://github.com/valexsantos'

    settings :partial => 'testit/setting'

    project_module :testit do
        permission :view_testcases, {
            'testit' => [:index ],
            'testit_test_suites' => [:index, :show ],
            'testit_test_cases'  => [:index, :show ],
            'testit_test_plans'  => [:index, :show, :list ],
            'testit_test_runs'   => [:index, :show],
            'testit_relations'   => [:index ],
            'testit_reports'     => [:index]
        }
        permission :manage_testcases, {
            'testit' => [:index ],
            'testit_test_suites' => [:new, :edit, :destroy, :create, :update, :copy, :move, :add_tc, :rm_tc ],
            'testit_test_cases'  => [:new, :edit, :destroy, :create, :update, :copy, :move, :add_tr ],
            'testit_test_plans'  => [:new, :edit, :destroy, :create, :update, :copy, :add_tc, :rm_tc],
            'testit_test_runs'   => [:new, :edit, :destroy, :create, :update  ],
            'testit_relations'   => [:new, :edit, :destroy, :create, :update  ],
            'testit_reports'     => [:index]
        }, :require => :member

        permission :setting_testcases, {
            'testit' => [:index ],
            'testit_settings' => [:index, :show, :edit],
        }, :require => :member
    end

    menu :project_menu, :testit, { :controller => :testit, :action => :index },
        :caption => :label_testit,
        :param => :project_id


end

