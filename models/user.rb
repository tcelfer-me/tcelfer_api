# frozen_string_literal: true

require 'bcrypt'
require 'sequel'
require 'sequel/plugins/json_serializer'

module TcelferApi
  # Errors pertaining to the user model
  class UserError < StandardError; end

  # Model for `users` table
  # This model will also support enforcement of bcrypt for storing passwords
  class User < Sequel::Model(:users)
    plugin :json_serializer

    # These keys are what are returned to the user
    EXPORT_KEYS = %i[id username email created_on].freeze
    PASSWD_LENGTH_RANGE = (12..55)

    # @param [String] clear_text
    def password=(clear_text)
      validate_password(clear_text)

      self.password_v1 = BCrypt::Password.create(clear_text)
    end

    # @param [String] clear_text
    def authenticate(clear_text)
      BCrypt::Password.new(password_v1) == clear_text
    end

    private

    def validate_password(password)
      return if PASSWD_LENGTH_RANGE.include?(password.length)

      raise UserError, "Password needs to be #{PASSWD_LENGTH_RANGE.to_s.sub('..', ' to ')} characters"
    end
  end
end
