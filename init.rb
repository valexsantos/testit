require 'redmine'
require 'testit_projects_helper_patch'
require 'testit_issue_patch'
require_dependency 'testit/hooks'

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
    version '0.0.8'
    url 'https://github.com/valexsantos/testit'
    author_url 'https://github.com/valexsantos'

    settings :partial => 'testit/setting'

    project_module :testit do
        permission :view_testcases, {
            'testit' => [:index ],
            'testit_issues' => [:index, :show ],
            'testit_suites' => [ :show ],
            'testit_tests'  => [:index, :show ],
            'testit_plans'  => [:index, :show, :list ],
            'testit_runs'   => [:index, :show],
            'testit_relations'   => [:show ],
            'testit_reports'     => [:index]
        }
        permission :manage_testcases, {
            'testit' => [:index ],
            'testit_issues' => [:new, :edit, :destroy, :create, :update, :copy, :move],
            'testit_suites' => [:new, :edit, :destroy, :create, :update, :copy, :move],
            'testit_tests'  => [:new, :edit, :destroy, :create, :update, :copy, :move],
            'testit_plans'  => [:new, :edit, :destroy, :create, :update, :copy ],
            'testit_runs'   => [:new, :edit, :destroy, :create, :update  ],
            'testit_relations'   => [:destroy, :create, :new_tc, :new_tr, :new_ts, :new_tp, :new_req ],
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

