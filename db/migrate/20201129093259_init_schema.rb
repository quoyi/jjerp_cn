class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "action_text_rich_texts" do |t|
      t.string "name", null: false
      t.text "body"
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
    end
    create_table "active_storage_attachments" do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.string "service_name", null: false
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.datetime "created_at", null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "active_storage_variant_records" do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    end
    create_table "agents" do |t|
      t.string "name", default: "", null: false
      t.string "province"
      t.string "city"
      t.string "district"
      t.string "town"
      t.string "address", default: "", null: false
      t.string "full_name", null: false
      t.string "contacts"
      t.string "mobile"
      t.string "e_account"
      t.string "fax"
      t.string "email"
      t.string "wechar"
      t.decimal "balance", precision: 12, scale: 2, default: "0.0", null: false
      t.decimal "arrear", precision: 12, scale: 2, default: "0.0", null: false
      t.decimal "history", precision: 12, scale: 2, default: "0.0", null: false
      t.string "logistics"
      t.integer "order_condition"
      t.integer "send_condition"
      t.string "cycle"
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "delivery_address", default: "", null: false
      t.index ["full_name"], name: "index_agents_on_full_name"
      t.index ["name"], name: "index_agents_on_name"
    end
    create_table "banks" do |t|
      t.string "name"
      t.string "bank_name"
      t.string "bank_card"
      t.decimal "balance", precision: 12, scale: 2, default: "0.0"
      t.decimal "incomes", precision: 12, scale: 2, default: "0.0"
      t.decimal "expends", precision: 12, scale: 2, default: "0.0"
      t.boolean "is_default", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["is_default"], name: "index_banks_on_is_default"
    end
    create_table "cities" do |t|
      t.bigint "province_id"
      t.string "name"
      t.index ["province_id", "name"], name: "index_cities_on_province_id_and_name", unique: true
      t.index ["province_id"], name: "index_cities_on_province_id"
    end
    create_table "craft_categories" do |t|
      t.string "full_name", default: "", null: false
      t.string "uom", default: ""
      t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["full_name"], name: "index_craft_categories_on_full_name", unique: true
    end
    create_table "crafts" do |t|
      t.bigint "order_id"
      t.bigint "craft_category_id"
      t.string "full_name", default: ""
      t.string "uom"
      t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "number", precision: 8, scale: 2, default: "1.0", null: false
      t.string "note"
      t.boolean "status"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["craft_category_id"], name: "index_crafts_on_craft_category_id"
      t.index ["full_name"], name: "index_crafts_on_full_name"
      t.index ["order_id"], name: "index_crafts_on_order_id"
    end
    create_table "departments" do |t|
      t.string "name", null: false
      t.string "full_name", default: "", null: false
      t.bigint "user_id"
      t.integer "total"
      t.text "desc"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["full_name"], name: "index_departments_on_full_name"
      t.index ["name"], name: "index_departments_on_name"
      t.index ["user_id"], name: "index_departments_on_user_id"
    end
    create_table "districts" do |t|
      t.bigint "city_id"
      t.string "name"
      t.index ["city_id", "name"], name: "index_districts_on_city_id_and_name", unique: true
      t.index ["city_id"], name: "index_districts_on_city_id"
    end
    create_table "expends" do |t|
      t.string "name"
      t.bigint "bank_id"
      t.string "reason"
      t.decimal "money", precision: 12, scale: 2, default: "0.0"
      t.string "username"
      t.datetime "expend_at"
      t.integer "status"
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["bank_id"], name: "index_expends_on_bank_id"
    end
    create_table "incomes" do |t|
      t.string "name"
      t.bigint "bank_id"
      t.string "reason"
      t.decimal "money", precision: 12, scale: 2, default: "0.0"
      t.string "username"
      t.datetime "income_at"
      t.integer "status"
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.string "source", default: ""
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.bigint "indent_id"
      t.bigint "order_id"
      t.bigint "agent_id"
      t.index ["agent_id"], name: "index_incomes_on_agent_id"
      t.index ["bank_id"], name: "index_incomes_on_bank_id"
      t.index ["income_at"], name: "index_incomes_on_income_at"
      t.index ["indent_id"], name: "index_incomes_on_indent_id"
      t.index ["order_id"], name: "index_incomes_on_order_id"
    end
    create_table "indents" do |t|
      t.string "name", null: false
      t.bigint "agent_id", null: false
      t.string "customer"
      t.date "verify_at"
      t.date "require_at"
      t.string "logistics"
      t.string "delivery_address"
      t.integer "status", default: 0
      t.string "note"
      t.decimal "amount", precision: 8, scale: 2, default: "0.0"
      t.decimal "arrear", precision: 8, scale: 2, default: "0.0"
      t.decimal "total_history", precision: 8, scale: 2, default: "0.0"
      t.decimal "total_arrear", precision: 8, scale: 2, default: "0.0"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "max_status", default: 0, null: false
      t.index ["agent_id"], name: "index_indents_on_agent_id"
      t.index ["name"], name: "index_indents_on_name"
    end
    create_table "material_categories" do |t|
      t.integer "oftype", null: false
      t.string "name"
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["oftype"], name: "index_material_categories_on_oftype"
    end
    create_table "materials" do |t|
      t.string "name", default: "", null: false
      t.string "full_name", null: false
      t.integer "ply", null: false
      t.integer "texture", null: false
      t.integer "color", null: false
      t.integer "store", default: 1, null: false
      t.decimal "buy", precision: 8, scale: 2, null: false
      t.decimal "price", precision: 8, scale: 2, null: false
      t.string "uom"
      t.bigint "supply_id"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["ply", "texture", "color"], name: "index_materials_on_ply_and_texture_and_color", unique: true
      t.index ["supply_id"], name: "index_materials_on_supply_id"
    end
    create_table "offers" do |t|
      t.bigint "indent_id"
      t.bigint "order_id"
      t.integer "display"
      t.integer "item_id"
      t.integer "item_type", default: 0
      t.string "item_name"
      t.string "uom"
      t.decimal "number", precision: 10, scale: 6, default: "0.0"
      t.decimal "price", precision: 8, scale: 2, default: "0.0"
      t.decimal "sum", precision: 12, scale: 2, default: "0.0"
      t.decimal "total", precision: 12, scale: 2, default: "0.0"
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["indent_id"], name: "index_offers_on_indent_id"
      t.index ["item_id", "item_type", "order_id", "price"], name: "index_offers_on_item_id_and_item_type_and_order_id_and_price", unique: true
      t.index ["order_id"], name: "index_offers_on_order_id"
    end
    create_table "order_categories" do |t|
      t.string "name", null: false
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "orders" do |t|
      t.bigint "indent_id", null: false
      t.string "name", default: "", null: false
      t.bigint "order_category_id", default: 1, null: false
      t.string "customer"
      t.integer "ply", default: 0, null: false
      t.integer "texture", default: 0, null: false
      t.integer "color", default: 0, null: false
      t.integer "length", default: 1, null: false
      t.integer "width", default: 1, null: false
      t.integer "height", default: 1, null: false
      t.integer "number", default: 1, null: false
      t.decimal "price", precision: 12, scale: 2, default: "0.0"
      t.decimal "arrear", precision: 12, scale: 2, default: "0.0"
      t.decimal "material_price", precision: 8, scale: 2, default: "0.0"
      t.integer "status", default: 0, null: false
      t.integer "oftype", default: 0, null: false
      t.integer "package_num", default: 0, null: false
      t.string "note"
      t.string "delivery_address", default: "", null: false
      t.boolean "deleted", default: false, null: false
      t.boolean "is_use_order_material", default: false
      t.bigint "agent_id"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "index"
      t.integer "handler", default: 0, null: false
      t.decimal "material_number", precision: 8, scale: 2, default: "0.0", null: false
      t.datetime "produced_at"
      t.datetime "packaged_at"
      t.datetime "sent_at"
      t.datetime "over_at"
      t.index ["agent_id"], name: "index_orders_on_agent_id"
      t.index ["indent_id"], name: "index_orders_on_indent_id"
      t.index ["name"], name: "index_orders_on_name", unique: true
      t.index ["order_category_id"], name: "index_orders_on_order_category_id"
    end
    create_table "packages" do |t|
      t.bigint "order_id", null: false
      t.string "unit_ids", default: ""
      t.string "part_ids", default: ""
      t.string "print_size"
      t.integer "label_size", default: 0
      t.boolean "is_batch", default: false, null: false
      t.index ["order_id"], name: "index_packages_on_order_id"
    end
    create_table "part_categories" do |t|
      t.bigint "parent_id", default: 1
      t.string "name", default: "", null: false
      t.decimal "buy", precision: 8, scale: 2, default: "0.0"
      t.decimal "price", precision: 8, scale: 2, default: "0.0"
      t.integer "store", default: 0, null: false
      t.string "uom"
      t.string "brand"
      t.bigint "supply_id"
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["name"], name: "index_part_categories_on_name", unique: true
      t.index ["parent_id"], name: "index_part_categories_on_parent_id"
      t.index ["supply_id"], name: "index_part_categories_on_supply_id"
    end
    create_table "parts" do |t|
      t.bigint "part_category_id", null: false
      t.bigint "order_id", null: false
      t.string "name"
      t.decimal "buy", precision: 8, scale: 2
      t.decimal "price", precision: 8, scale: 2
      t.integer "store", default: 1, null: false
      t.string "uom"
      t.decimal "number", precision: 8, scale: 4, default: "1.0", null: false
      t.string "brand"
      t.string "note"
      t.bigint "supply_id", null: false
      t.boolean "is_printed", default: false
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["name"], name: "index_parts_on_name"
      t.index ["order_id"], name: "index_parts_on_order_id"
      t.index ["part_category_id"], name: "index_parts_on_part_category_id"
      t.index ["supply_id"], name: "index_parts_on_supply_id"
    end
    create_table "permissions" do |t|
      t.string "name"
      t.string "klass", null: false
      t.string "actions", null: false
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "provinces" do |t|
      t.string "name"
    end
    create_table "role_permissions" do |t|
      t.bigint "role_id"
      t.bigint "permission_id"
      t.string "klass", null: false
      t.string "actions", null: false
      t.string "note"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
      t.index ["role_id"], name: "index_role_permissions_on_role_id"
    end
    create_table "roles" do |t|
      t.string "name", null: false
      t.string "nick"
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.boolean "display", default: true, null: false
      t.index ["name"], name: "index_roles_on_name"
    end
    create_table "sent_lists" do |t|
      t.string "name"
      t.integer "total"
      t.string "created_by"
      t.boolean "deleted"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "sents" do |t|
      t.integer "owner_id", null: false
      t.string "owner_type", null: false
      t.integer "sent_list_id"
      t.string "name"
      t.datetime "sent_at"
      t.string "area"
      t.string "receiver", null: false
      t.string "contact", null: false
      t.integer "cupboard", default: 0
      t.integer "robe", default: 0
      t.integer "door", default: 0
      t.integer "part", default: 0
      t.decimal "collection", precision: 12, scale: 2, default: "0.0"
      t.string "logistics", default: "", null: false
      t.string "logistics_code", default: "", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "supplies" do |t|
      t.string "name", null: false
      t.string "full_name", null: false
      t.string "mobile"
      t.string "bank_account"
      t.string "address"
      t.string "note"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["full_name"], name: "index_supplies_on_full_name"
      t.index ["name"], name: "index_supplies_on_name"
    end
    create_table "tasks" do |t|
      t.bigint "order_id"
      t.integer "item_id"
      t.string "item_type"
      t.string "sequence"
      t.decimal "area", precision: 9, scale: 6
      t.integer "mix_status", default: 0
      t.decimal "availability", precision: 8, scale: 2
      t.integer "work", default: 0
      t.integer "state"
      t.integer "number"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["item_id"], name: "index_tasks_on_item_id"
      t.index ["order_id"], name: "index_tasks_on_order_id"
    end
    create_table "templates" do |t|
      t.string "name", null: false
      t.integer "creator", null: false
      t.decimal "price", precision: 8, scale: 2, default: "0.0"
      t.integer "times", default: 0
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["name"], name: "index_templates_on_name"
    end
    create_table "unit_categories" do |t|
      t.string "name", null: false
      t.string "note"
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "units" do |t|
      t.bigint "unit_category_id", default: 1
      t.bigint "order_id"
      t.string "name", default: "", null: false
      t.string "full_name"
      t.bigint "material_id"
      t.integer "ply", default: 1
      t.integer "texture"
      t.integer "color"
      t.integer "length", default: 1, null: false
      t.integer "width", default: 1, null: false
      t.decimal "number", precision: 8, scale: 2, default: "0.0", null: false
      t.string "uom"
      t.decimal "price", precision: 8, scale: 2, default: "0.0"
      t.string "size", default: ""
      t.string "note"
      t.bigint "supply_id"
      t.boolean "is_custom", default: false
      t.boolean "is_printed", default: false
      t.string "edge"
      t.string "customer"
      t.integer "out_edge_thick", default: 0, null: false
      t.integer "in_edge_thick", default: 0, null: false
      t.string "back_texture"
      t.string "door_type"
      t.string "door_mould"
      t.string "door_handle_type"
      t.string "door_edge_type"
      t.integer "door_edge_thick"
      t.integer "state", default: 0
      t.string "craft"
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["material_id"], name: "index_units_on_material_id"
      t.index ["name"], name: "index_units_on_name"
      t.index ["order_id"], name: "index_units_on_order_id"
      t.index ["supply_id"], name: "index_units_on_supply_id"
      t.index ["unit_category_id"], name: "index_units_on_unit_category_id"
    end
    create_table "uoms" do |t|
      t.string "name", default: "", null: false
      t.string "val"
      t.string "note", default: ""
      t.boolean "deleted", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["name"], name: "index_uoms_on_name", unique: true
    end
    create_table "user_categories" do |t|
      t.string "serial", null: false
      t.string "name", null: false
      t.string "nick", default: ""
      t.boolean "visible", default: true, null: false
      t.boolean "deleted", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["name"], name: "index_user_categories_on_name"
      t.index ["serial"], name: "index_user_categories_on_serial"
    end
    create_table "user_roles" do |t|
      t.bigint "user_id"
      t.bigint "role_id"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["role_id"], name: "index_user_roles_on_role_id"
      t.index ["user_id"], name: "index_user_roles_on_user_id"
    end
    create_table "users" do |t|
      t.integer "user_category", default: 0, null: false
      t.string "username", default: "", null: false
      t.string "mobile", default: "", null: false
      t.string "name"
      t.string "cert"
      t.boolean "deleted", default: false, null: false
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "print_size"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["mobile"], name: "index_users_on_mobile"
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["username"], name: "index_users_on_username"
    end
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "cities", "provinces"
    add_foreign_key "districts", "cities"
    add_foreign_key "materials", "supplies"
    add_foreign_key "tasks", "orders"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
