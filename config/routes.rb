
match 'projects/:project_id/testit/issues/(:action(/:id))',    :controller => 'testit_issues', via: [:get, :post, :patch]
match 'projects/:project_id/testit/tests/(:action(/:id))',     :controller => 'testit_tests',  via: [:get, :post, :patch]
match 'projects/:project_id/testit/suites/(:action(/:id))',    :controller => 'testit_suites', via: [:get, :post, :patch]
match 'projects/:project_id/testit/plans/(:action(/:id))',     :controller => 'testit_plans',  via: [:get, :post]
match 'projects/:project_id/testit/runs/(:action(/:id))',      :controller => 'testit_runs',   via: [:get, :post, :patch]
match 'projects/:project_id/testit/relations/(:action(/:id))', :controller => 'testit_relations', via: [:get, :post, :patch, :delete ]
match 'projects/:project_id/testit/reports/(:action(/:id))',   :controller => 'testit_reports',   via: [:get ]
match 'projects/:project_id/testit/settings/(:action(/:id))',  :controller => 'testit_settings',  via: [:get, :post, :patch]

get 'projects/:project_id/testit', :to => 'testit#index'


