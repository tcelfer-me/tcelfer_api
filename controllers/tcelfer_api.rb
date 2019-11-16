# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'

require 'tcelfer_api/utils'
require 'tcelfer_api/helpers'

module TcelferApi
  # Beep bop
  class TcelferApiApp < Sinatra::Base
    helpers Helpers

    enable :logging

    configure :development do
      register Sinatra::Reloader
    end

    set :token_auth do |_|
      condition do
        unless valid_auth_token?
          halt 401, { 'WWW-Authenticate' => %(Basic realm="TcelferApi token_auth") }, @errors.to_json
        end
      end
    end

    get '/ratings', provides: :json, token_auth: true do
      Rating.to_json
    end

    post '/date', provides: :json, token_auth: true do
      payload = parse_payload
      rating  = validate_rating(payload[:rating])
      date    = payload[:date] || Date.today
      halt 409, { err: 'Duplicate day for user' }.to_json if Day.find(user_id: @current_user.id, date: date)

      new_day = Day.new(
        user_id:   @current_user.id,
        date:      date,
        rating_id: rating,
        notes:     payload[:notes]
      )
      new_day.save.to_json
    end

    get '/date', provides: :json, token_auth: true do
      dates = Day.where(date: date_range(params[:from], params[:to]))
      halt 404, { err: 'No data found for that you for those dates' }.to_json unless dates

      dates.to_json
    end

    put '/date/:date', provides: :json, token_auth: true do
      date          = params.delete('date')
      payload       = parse_payload
      day           = Day.find(user_id: @current_user.id, date: date)
      day.rating_id = validate_rating(payload[:rating]) if payload.key?('rating')
      day.notes     = payload['notes'] if payload.key?('notes')
      day.save.to_json
    end

    not_found do
      { err: 'Not Found' }.to_json
    end
  end
end
