# frozen_string_literal: true

require 'sequel'
require 'sequel/plugins/json_serializer'

module TcelferApi
  # Model for `days` table
  class Day < Sequel::Model(:days)
    plugin :json_serializer
    # Pretty format for a Day model
    # [.user][]2019-01-17]: Normal, Average Day
    # @return [String]
    def to_s
      str = "[#{User[user_id].username}][#{date}] #{Rating[rating_id].text}"
      str += " || Notes: #{notes}" unless notes.nil?
      str
    end
  end
end
