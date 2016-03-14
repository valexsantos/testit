
match 'projects/:project_id/testit/test_cases/(:action(/:id))', :controller => 'testit_test_cases', via: [:get, :post, :patch]
match 'projects/:project_id/testit/test_suites/(:action(/:id))', :controller => 'testit_test_suites', via: [:get, :post, :patch]
match 'projects/:project_id/testit/test_plans/(:action(/:id))', :controller => 'testit_test_plans', via: [:get, :post]
match 'projects/:project_id/testit/test_runs/(:action(/:id))', :controller => 'testit_test_runs', via: [:get, :post, :patch]
match 'projects/:project_id/testit/relations/(:action(/:id))', :controller => 'testit_relations', via: [:get, :post, :patch]
match 'projects/:project_id/testit/reports/(:action(/:id))', :controller => 'testit_reports', via: [:get ]
match 'projects/:project_id/testit/settings/(:action(/:id))', :controller => 'testit_settings', via: [:get, :post, :patch]

get 'projects/:project_id/testit', :to => 'testit#index'


