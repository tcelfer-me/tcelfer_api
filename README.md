# TcelferApi <sub>[t]cel-fer</sub> #
### Track your mood from day to day, API edition ###
-- --

#### Database config ####
 1. `mv config/tc_api.{sample-,}dev.yml`
 2. create a postgresql db, user.
 3. set creds in `config/tc_api.ENV.yml`

#### Usage ####
- `bundle install`
- `bundle exec rackup`
