# frozen_string_literal: true

require 'bcrypt'
require 'sequel'
require 'sequel/plugins/json_serializer'

module TcelferApi
  # Model for `users` table
  # This model will also support enforcement of bcrypt for storing passwords
  class User < Sequel::Model(:users)
    plugin :json_serializer

    # @param [String] clear_text
    def password=(clear_text)
      return if clear_text.nil? || clear_text =~ /^\s*$/

      self.password_v1 = BCrypt::Password.create(clear_text)
    end

    # @param [String] clear_text
    def authenticate(clear_text)
      BCrypt::Password.new(password_v1) == clear_text
    end
  end
end
