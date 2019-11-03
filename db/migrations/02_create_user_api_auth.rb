# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :api_auth do
      uuid :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid :token, null: false
      foreign_key :user_id, :users, type: :uuid, null: false
      Time :created_on, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :last_used, null: true
      column :last_used_ip, :inet, null: true
      String :comment, null: false
    end
  end
end
