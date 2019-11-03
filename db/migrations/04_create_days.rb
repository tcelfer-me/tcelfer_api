# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :days do
      uuid :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      Date :date, default: Sequel::CURRENT_DATE
      String :notes, null: true
      foreign_key :rating_id, :ratings, type: :uuid, null: false
      foreign_key :user_id, :users, type: :uuid, null: false
      unique %i[date user_id]
    end
  end
end
