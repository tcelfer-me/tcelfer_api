# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'

require 'tcelfer_api/helpers'

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
      halt 409 if User.find(email: @payload[:email])

      auth_user = User.new(email: @payload[:email], password: @payload[:password])
      auth_user.save
      status 201
      { email: auth_user.email, created_on: auth_user.account_created }.to_json
    end

    set :authentication do |auth_type|
      condition do
        valid_user = authenticate_user(auth_type)
        halt 401, { 'WWW-Authenticate' => %(Basic realm="TcelferApi #{auth_type}") }, @errors.to_json unless valid_user
      end
    end

    post '/auth', provides: :json, authentication: :user_pass do
      AuthToken.new_tokens(@auth_user.id, nil, @payload.fetch(:refresh, false)).to_json
    end

    post '/refresh', provides: :json, authentication: :refresh do
      AuthToken.new_tokens(@auth_user.id, nil, false).to_json
    end
  end
end
