# frozen_string_literal: true

require 'bcrypt'

require 'sinatra/indifferent_hash'

module TcelferApi
  # Sinatra helper methods
  module Helpers
    # Parses JSON or Form based HTTP body
    # returns a hash with symbols (or indifferent access) for keys
    # @return [Hash]
    def parse_payload
      if params.empty?
        request.body.rewind # in case someone else read it
        JSON.parse(request.body.read, symbolize_names: true)
      else
        params.dup
      end
    rescue JSON::ParserError
      nil
    end

    # Returns a Range of dates
    # @param [String] start_str
    # @param [String] end_str
    # @return [Range]
    def date_range(start_str, end_str)
      Date.parse(start_str)..Date.parse(end_str)
    rescue ArgumentError => e
      halt 400, { err: 'Invalid date(s)', msg: e.message }.to_json
    end

    # Checks if the rating id passed in is valid
    # Valid means:
    #   exists
    #   UUID formatted
    #   exists in the `ratings` table
    # Returns the rating if valid
    # Halts with 400 - Bad Request if not
    #
    # @param [String] rating
    # @return [String]
    def validate_rating(rating)
      if rating.nil? || !uuid?(rating) || !Rating.find(id: rating)
        halt 400, { err: 'Invalid `rating`', valid_ratings: "GET #{url('/ratings')}" }.to_json
      end

      rating
    end

    # Checks if `str` is a valid formatted UUID
    # @param [String] str
    # @return [Boolean]
    def uuid?(str)
      str.size == 36 && str.match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
    end

    # Returns the credentials array from the `HTTP['AUTHORIZATION']` header
    # Currently uses HTTP BasicAuth for this
    # format: [username, password]
    # @return [Array]
    def http_authorization_to_creds
      @auth ||= Rack::Auth::Basic::Request.new request.env
      return unless @auth.provided? && @auth.basic?

      @auth.credentials
    end

    # Validates an AuthToken passed in via the `HTTP['AUTHORIZATION']` header
    # token is valid as long as it is present in the database
    #                and not currently expired
    # If any specific errors arise, they're added to the `@errors` instance var
    # @return [Boolean]
    def valid_auth_token?
      tok_id, tok_sec = http_authorization_to_creds
      halt 400, { err: 'token id is not a valid uuid' }.to_json unless uuid?(tok_id)

      fetched_token = AuthToken.first(id: tok_id)
      return false unless fetched_token

      unless fetched_token.expires_at > Time.now
        @errors = { err: 'expired token' }
        return false
      end

      return false unless fetched_token.authenticate tok_sec

      @current_user = User.find(id: fetched_token.user_id)
    end

    def authenticate_user(auth_type)
      creds = http_authorization_to_creds
      return false unless creds

      method("authenticate_#{auth_type}").call(*creds)
    end

    def authenticate_user_pass(email, password)
      @auth_user = User.find(email: email)
      return false unless @auth_user

      @get_refresh = true
      @auth_user.authenticate(password)
    end

    def authenticate_refresh(token_id, token_secret)
      halt 400, { err: 'token id is not a valid uuid' }.to_json unless uuid?(token_id)

      refresh_tok = AuthToken.find(id: token_id)
      return false unless refresh_tok

      unless refresh_tok.expires_at > Time.now
        @errors = { err: 'expired token' }
        return false
      end

      refresh_tok.authenticate(token_secret)
      @auth_user = User.find(id: refresh_tok.user_id)
    end
  end
end
