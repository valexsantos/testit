class CreateTestitRelations < ActiveRecord::Migration
    def self.up
        create_table "testit_relations", force: :cascade do |t|
            t.integer "issue_from_id", limit: 4,                null: false
            t.integer "issue_to_id",   limit: 4,                null: false
            t.string  "relation_type", limit: 255, default: "", null: false
            t.integer "delay",         limit: 4
        end

        add_index "testit_relations", ["issue_from_id", "issue_to_id"], name: "index_testit_relations_on_issue_from_id_and_issue_to_id", unique: true, using: :btree
        add_index "testit_relations", ["issue_from_id"], name: "index_testit_relations_on_issue_from_id", using: :btree
        add_index "testit_relations", ["issue_to_id"], name: "index_testit_relations_on_issue_to_id", using: :btree

    end

    def self.down
        drop_table :testit_relations
    end
end

