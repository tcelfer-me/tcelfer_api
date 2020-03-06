# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'

module TcelferApi
  # Various user management routes
  class UserManagement < Sinatra::Base
    helpers TcelferApi::Helpers
    configure :development, :production do
      enable :logging
    end

    configure :development do
      register Sinatra::Reloader
    end

    before do
      @payload = parse_payload
    end

    post '/new', provides: :json do
      halt 409 if User.where(username: @payload[:username]).or(email: @payload.fetch(:email, '')).any?

      auth_user = User.new(username: @payload[:username], password: @payload[:password])
      auth_user.email = @payload[:email] if @payload.key? :email
      auth_user.save
      status 201
      auth_user.to_hash.slice(*User::EXPORT_KEYS).to_json
    rescue TcelferApi::UserError => e
      halt 400, {}, { error: e.message }.to_json
    end

    set :authentication do |auth_type|
      condition do
        valid_user = authenticate_user(auth_type)
        halt 401, { 'WWW-Authenticate' => %(Basic realm="TcelferApi #{auth_type}") }, @errors.to_json unless valid_user
      end
    end

    post '/auth', provides: :json, authentication: :user_pass do
      AuthToken.new_tokens(
        @auth_user.id,
        @payload.fetch(:comment, nil),
        @payload.fetch(:refresh, false)
      ).to_json
    end

    post '/refresh', provides: :json, authentication: :refresh do
      AuthToken.new_tokens(@auth_user.id, nil, false).to_json
    end

    after do
      headers['X-Tcelfer-Api-Version'] = TcelferApi::VERSION
    end
  end
end
