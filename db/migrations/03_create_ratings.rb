# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :ratings do
      uuid :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      String :text, null: false
      Integer :color, null: false
      Integer :color_dark, null: true
      Integer :color_high_contrast, null: true
    end
  end
end
