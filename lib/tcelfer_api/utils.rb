# frozen_string_literal: true

require 'yaml'

# Huzzah
module TcelferApi
  # define the config here until I care to split it out more
  def self.config
    @config ||= Utils._default_config
  end

  # Utilities for TcelferApi and the config.ru file
  class Utils
    class Error < StandardError; end

    class << self
      attr_accessor :app_root

      # If the `ratings` table is empty, seed it with some sane data.
      def seed_ratings_table!
        return unless Rating.empty?

        seed_data = File.read(TcelferApi.config[:rating_seed_path])
        rating_seeds = Psych.safe_load(seed_data, symbolize_names: true)
        Rating.multi_insert(rating_seeds)
      end

      def _rack_env
        # Map ENV['RACK_ENV'] to something shorter please
        {
          'production'  => :prod,
          'development' => :dev
        }[ENV['RACK_ENV']&.downcase]
      end

      def _default_config
        main_conf_path = File.expand_path("config/tc_api.#{_rack_env}.yml", app_root)
        seed_file      = File.expand_path('config/default_ratings.yml', app_root)
        Hash.new { |h, _k| Hash.new(&h.default_proc) }.merge(
          **Psych.safe_load(File.read(main_conf_path), symbolize_names: true),
          rating_seed_path: seed_file
        )
      end
    end
  end
end
