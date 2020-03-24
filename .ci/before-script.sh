#!/bin/sh
set -e

ruby -v # Print out ruby version for debugging?
apk add --update httpie zsh less build-base postgresql-dev postgresql-client
gem install bundler -v '~> 2.1.4'

# Install dependencies into ./vendor/ruby
bundle config set path vendor

bundle install -j $(nproc)
