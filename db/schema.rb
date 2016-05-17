# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20010101010128) do

  create_table "agents", force: :cascade do |t|
    t.string   "serial",          limit: 255, default: "", null: false
    t.integer  "province_id",     limit: 4
    t.integer  "city_id",         limit: 4
    t.integer  "district_id",     limit: 4
    t.string   "address",         limit: 255
    t.string   "name",            limit: 255,              null: false
    t.string   "contacts",        limit: 255
    t.string   "mobile",          limit: 255
    t.string   "e_account",       limit: 255
    t.string   "fax",             limit: 255
    t.string   "email",           limit: 255
    t.string   "wechar",          limit: 255
    t.string   "logistics",       limit: 255
    t.integer  "order_condition", limit: 4
    t.integer  "send_condition",  limit: 4
    t.string   "cycle",           limit: 255
    t.string   "note",            limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "agents", ["name"], name: "index_agents_on_name", using: :btree
  add_index "agents", ["serial"], name: "index_agents_on_serial", using: :btree

  create_table "cities", force: :cascade do |t|
    t.integer "province_id", limit: 4
    t.string  "name",        limit: 255
  end

  add_index "cities", ["province_id", "name"], name: "index_cities_on_province_id_and_name", unique: true, using: :btree
  add_index "cities", ["province_id"], name: "index_cities_on_province_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "serial",     limit: 255,                null: false
    t.string   "name",       limit: 255,   default: "", null: false
    t.integer  "user_id",    limit: 4
    t.integer  "total",      limit: 4
    t.text     "desc",       limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "departments", ["name"], name: "index_departments_on_name", using: :btree
  add_index "departments", ["serial"], name: "index_departments_on_serial", using: :btree

  create_table "districts", force: :cascade do |t|
    t.integer "city_id", limit: 4
    t.string  "name",    limit: 255
  end

  add_index "districts", ["city_id", "name"], name: "index_districts_on_city_id_and_name", unique: true, using: :btree
  add_index "districts", ["city_id"], name: "index_districts_on_city_id", using: :btree

  create_table "indents", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.integer  "agent_id",   limit: 4,                   null: false
    t.string   "customer",   limit: 255
    t.datetime "verify_at"
    t.datetime "require_at"
    t.string   "note",       limit: 255
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "indents", ["agent_id"], name: "index_indents_on_agent_id", using: :btree
  add_index "indents", ["name"], name: "index_indents_on_name", using: :btree

  create_table "material_categories", force: :cascade do |t|
    t.integer  "oftype",     limit: 4,   null: false
    t.string   "name",       limit: 255
    t.string   "note",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string   "serial",     limit: 255,                         default: "", null: false
    t.string   "name",       limit: 255
    t.integer  "ply",        limit: 4,                                        null: false
    t.integer  "texture",    limit: 4,                                        null: false
    t.integer  "color",      limit: 4,                                        null: false
    t.integer  "store",      limit: 4,                           default: 1,  null: false
    t.decimal  "buy",                    precision: 8, scale: 2,              null: false
    t.decimal  "sell",                   precision: 8, scale: 2,              null: false
    t.string   "unit",       limit: 255
    t.integer  "supply_id",  limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "materials", ["supply_id"], name: "index_materials_on_supply_id", using: :btree

  create_table "order_categories", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "note",       limit: 255
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "indent_id",         limit: 4,                   null: false
    t.string   "name",              limit: 255,                 null: false
    t.integer  "order_category_id", limit: 4,                   null: false
    t.integer  "ply",               limit: 4,   default: 0,     null: false
    t.integer  "texture",           limit: 4,   default: 0,     null: false
    t.integer  "color",             limit: 4,   default: 0,     null: false
    t.integer  "length",            limit: 4,   default: 0,     null: false
    t.integer  "width",             limit: 4,   default: 0,     null: false
    t.integer  "height",            limit: 4,   default: 0,     null: false
    t.integer  "number",            limit: 4,   default: 0,     null: false
    t.integer  "status",            limit: 4,   default: 0,     null: false
    t.string   "note",              limit: 255
    t.boolean  "deleted",                       default: false, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "orders", ["indent_id"], name: "index_orders_on_indent_id", using: :btree

  create_table "part_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "note",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "parts", force: :cascade do |t|
    t.integer  "part_category_id", limit: 4,                                       null: false
    t.string   "name",             limit: 255,                                     null: false
    t.decimal  "buy",                          precision: 8, scale: 2
    t.decimal  "sell",                         precision: 8, scale: 2
    t.integer  "store",            limit: 4,                           default: 0, null: false
    t.string   "brand",            limit: 255
    t.integer  "supply_id",        limit: 4,                                       null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
  end

  add_index "parts", ["name"], name: "index_parts_on_name", using: :btree
  add_index "parts", ["part_category_id"], name: "index_parts_on_part_category_id", using: :btree
  add_index "parts", ["supply_id"], name: "index_parts_on_supply_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "klass",      limit: 255,                 null: false
    t.string   "actions",    limit: 255,                 null: false
    t.string   "note",       limit: 255
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "provinces", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer  "role_id",       limit: 4
    t.integer  "permission_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "role_permissions", ["permission_id"], name: "index_role_permissions_on_permission_id", using: :btree
  add_index "role_permissions", ["role_id"], name: "index_role_permissions_on_role_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "nick",       limit: 255
    t.string   "note",       limit: 255
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "supplies", force: :cascade do |t|
    t.string   "serial",       limit: 255, null: false
    t.string   "name",         limit: 255, null: false
    t.string   "mobile",       limit: 255
    t.string   "bank_account", limit: 255
    t.string   "address",      limit: 255
    t.string   "note",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "supplies", ["name"], name: "index_supplies_on_name", using: :btree
  add_index "supplies", ["serial"], name: "index_supplies_on_serial", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "order_id",     limit: 4
    t.integer  "item_id",      limit: 4
    t.string   "item_type",    limit: 255
    t.string   "sequence",     limit: 255
    t.decimal  "area",                     precision: 9, scale: 6
    t.integer  "mix_status",   limit: 4,                           default: 0
    t.decimal  "availability",             precision: 8, scale: 2
    t.integer  "work",         limit: 4,                           default: 0
    t.integer  "state",        limit: 4
    t.integer  "number",       limit: 4
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "tasks", ["item_id"], name: "index_tasks_on_item_id", using: :btree
  add_index "tasks", ["order_id"], name: "index_tasks_on_order_id", using: :btree

  create_table "unit_categories", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "note",       limit: 255
    t.boolean  "deleted",                default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "units", force: :cascade do |t|
    t.integer  "unit_category_id", limit: 4
    t.integer  "order_id",         limit: 4
    t.string   "serial",           limit: 255,             null: false
    t.string   "unit_name",        limit: 255
    t.integer  "material_id",      limit: 4,               null: false
    t.integer  "ply",              limit: 4
    t.integer  "texture",          limit: 4
    t.integer  "color",            limit: 4
    t.integer  "length",           limit: 4
    t.integer  "width",            limit: 4
    t.integer  "number",           limit: 4
    t.string   "size",             limit: 255
    t.string   "note",             limit: 255
    t.string   "edge",             limit: 255
    t.string   "customer",         limit: 255
    t.integer  "out_edge_thick",   limit: 4
    t.integer  "in_edge_thick",    limit: 4
    t.string   "back_texture",     limit: 255
    t.string   "door_type",        limit: 255
    t.string   "door_mould",       limit: 255
    t.string   "door_handle_type", limit: 255
    t.string   "door_edge_type",   limit: 255
    t.integer  "door_edge_thick",  limit: 4
    t.integer  "task_id",          limit: 4
    t.integer  "state",            limit: 4,   default: 0
    t.string   "craft",            limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "units", ["order_id"], name: "index_units_on_order_id", using: :btree
  add_index "units", ["serial"], name: "index_units_on_serial", using: :btree
  add_index "units", ["task_id"], name: "index_units_on_task_id", using: :btree
  add_index "units", ["unit_category_id"], name: "index_units_on_unit_category_id", using: :btree

  create_table "user_categories", force: :cascade do |t|
    t.string   "serial",     limit: 255,                null: false
    t.string   "name",       limit: 255,                null: false
    t.string   "nick",       limit: 255, default: ""
    t.boolean  "visible",                default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "user_categories", ["name"], name: "index_user_categories_on_name", using: :btree
  add_index "user_categories", ["serial"], name: "index_user_categories_on_serial", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "role_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "user_category",          limit: 4,   default: 0,     null: false
    t.string   "username",               limit: 255, default: "",    null: false
    t.string   "mobile",                 limit: 255, default: "",    null: false
    t.string   "name",                   limit: 255
    t.string   "cert",                   limit: 255
    t.boolean  "deleted",                            default: false, null: false
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  add_foreign_key "cities", "provinces"
  add_foreign_key "districts", "cities"
  add_foreign_key "materials", "supplies"
  add_foreign_key "tasks", "orders"
  add_foreign_key "units", "orders"
  add_foreign_key "units", "tasks"
end
