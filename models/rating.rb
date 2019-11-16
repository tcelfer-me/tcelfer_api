# frozen_string_literal: true

require 'sequel'
require 'sequel/plugins/json_serializer'

module TcelferApi
  # Model for `rating` table
  class Rating < Sequel::Model(:ratings)
    plugin :json_serializer
  end
end
