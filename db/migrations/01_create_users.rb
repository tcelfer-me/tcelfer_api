# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :users do
      uuid :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      String :email, null: false, unique: true
      String :password_v1, null: false
      Time :pass_last_changed, default: Sequel::CURRENT_TIMESTAMP
      Time :account_created, default: Sequel::CURRENT_TIMESTAMP
      Time :last_edited, default: Sequel::CURRENT_TIMESTAMP
      Time :last_login, null: true
    end
  end
end
