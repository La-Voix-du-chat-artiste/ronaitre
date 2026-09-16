# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_16_150000) do
  create_table "consumptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "note"
    t.datetime "occurred_at", null: false
    t.decimal "quantity", precision: 10, scale: 2
    t.integer "track_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["track_id", "occurred_at"], name: "index_consumptions_on_track_id_and_occurred_at"
    t.index ["track_id"], name: "index_consumptions_on_track_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "a_id", null: false
    t.integer "b_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.integer "membership_id", null: false
    t.datetime "updated_at", null: false
    t.index ["a_id", "b_id"], name: "index_conversations_on_a_id_and_b_id", unique: true
    t.index ["a_id"], name: "index_conversations_on_a_id"
    t.index ["b_id"], name: "index_conversations_on_b_id"
    t.index ["membership_id"], name: "index_conversations_on_membership_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "grants", force: :cascade do |t|
    t.boolean "can_message", default: true, null: false
    t.boolean "can_view_details", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "membership_id", null: false
    t.integer "track_id", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id", "track_id"], name: "index_grants_on_membership_id_and_track_id", unique: true
    t.index ["membership_id"], name: "index_grants_on_membership_id"
    t.index ["track_id"], name: "index_grants_on_track_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invite_token"
    t.string "kind", default: "proche", null: false
    t.integer "member_id", null: false
    t.integer "owner_id", null: false
    t.string "status", default: "invited", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_token"], name: "index_memberships_on_invite_token", unique: true
    t.index ["member_id"], name: "index_memberships_on_member_id"
    t.index ["owner_id", "member_id", "kind"], name: "index_memberships_on_owner_id_and_member_id_and_kind", unique: true, where: "status != 'revoked'"
    t.index ["owner_id"], name: "index_memberships_on_owner_id"
    t.index ["status"], name: "index_memberships_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.string "channel", default: "site", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.datetime "celebrated_at"
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.datetime "reached_at"
    t.integer "seconds", null: false
    t.integer "track_id", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id", "seconds"], name: "index_milestones_on_track_id_and_seconds", unique: true
    t.index ["track_id"], name: "index_milestones_on_track_id"
  end

  create_table "presets", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "color", default: "primary"
    t.datetime "created_at", null: false
    t.string "guide_slug"
    t.string "icon", default: "circle"
    t.json "milestones", default: []
    t.string "name", null: false
    t.string "slug", null: false
    t.string "unit_word"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_presets_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "share_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "last_viewed_at"
    t.string "password_digest"
    t.datetime "revoked_at"
    t.string "token", null: false
    t.integer "track_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["token"], name: "index_share_links_on_token", unique: true
    t.index ["track_id"], name: "index_share_links_on_track_id"
    t.index ["user_id"], name: "index_share_links_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.datetime "closed_at"
    t.string "color", default: "primary"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "paused_seconds"
    t.integer "personal_best_seconds", default: 0, null: false
    t.json "preset_config", default: {}
    t.integer "preset_id"
    t.datetime "quit_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["preset_id"], name: "index_tracks_on_preset_id"
    t.index ["user_id", "status"], name: "index_tracks_on_user_id_and_status"
    t.index ["user_id"], name: "index_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "anonymous", default: false, null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.string "role", default: "suivi", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "consumptions", "tracks"
  add_foreign_key "conversations", "memberships"
  add_foreign_key "conversations", "users", column: "a_id"
  add_foreign_key "conversations", "users", column: "b_id"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "grants", "memberships"
  add_foreign_key "grants", "tracks"
  add_foreign_key "memberships", "users", column: "member_id"
  add_foreign_key "memberships", "users", column: "owner_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "milestones", "tracks"
  add_foreign_key "sessions", "users"
  add_foreign_key "share_links", "tracks"
  add_foreign_key "share_links", "users"
  add_foreign_key "tracks", "presets"
  add_foreign_key "tracks", "users"
end
