class CreateTestitSettings < ActiveRecord::Migration
    def self.up
        create_table :testit_settings do |t|
            t.references :project, :null => false
            t.column :bug_tracker, :integer
            t.column :requirement_tracker, :string
            t.column :test_case_tracker,  :integer 
            t.column :test_suite_tracker, :integer 
            t.column :test_plan_tracker,  :integer 
            t.column :test_run_tracker,   :integer 
        end
        add_index :testit_settings, :project_id, :name => 'IDX_TESTIT_SETTINGS_01'
    end

    def self.down
        drop_table :testit_settings
    end
end

