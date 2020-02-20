# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'

require 'sequel'
require 'sequel/plugins/json_serializer'

module TcelferApi
  # Model for the `api_auth` table
  class AuthToken < Sequel::Model(:auth_tokens)
    # These keys are what are returned to the user
    EXPORT_KEYS = %i[id expires_at comment created_on].freeze

    class << self
      # Use this in a `rake cron` task perhaps?
      def clean_expired!
        AuthToken.where(Sequel[:expires_at] < DateTime.now).delete
      end

      def new_tokens(user_id, comment, get_refresh)
        { access: new_token(user_id, :access, comment) }.tap do |tok|
          tok[:refresh] = new_token(user_id, :refresh) if get_refresh
        end
      end

      private

      RANDOM_BYTES = 20

      def new_token(user_id, token_type, comment = nil)
        ret_token = { token: SecureRandom.hex(RANDOM_BYTES) }
        tok = new(
          token:      ret_token[:token],
          user_id:    user_id,
          comment:    comment,
          token_type: token_type
        )
        tok.save
        ret_token.merge(tok.to_hash.slice(*EXPORT_KEYS))
      end
    end

    plugin :json_serializer

    def before_save
      valid_for_key = :"#{'refresh_' if token_type == 'refresh'}valid_for"
      valid_for = TcelferApi.config[:tokens][valid_for_key]
      self.expires_at = DateTime.now + valid_for
      super
    end

    def token=(clear_text)
      return if clear_text.nil? || clear_text =~ /^\s*$/

      self.token_v1 = BCrypt::Password.create(clear_text)
    end

    def authenticate(clear_text)
      BCrypt::Password.new(token_v1) == clear_text
    end
  end
end
