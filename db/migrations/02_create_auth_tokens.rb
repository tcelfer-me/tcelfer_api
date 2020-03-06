# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :auth_tokens do
      uuid :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      String :token_v1, null: false
      foreign_key :user_id, :users, type: :uuid, null: false
      DateTime :created_on, default: Sequel::CURRENT_TIMESTAMP
      DateTime :last_used, null: true
      column :last_used_ip, :inet, null: true
      String :comment, null: true
      DateTime :expires_at, null: false
      String :token_type, null: false
    end
  end
end
