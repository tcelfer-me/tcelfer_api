#!/usr/bin/env zsh

httpie="http -j --ignore-stdin --check-status"
echo 'Testing duplicate names/emails'
echo 'This should generate 3 users, and 6 409 replies'
usernames=( user1 user2 user3 )
emails=( user1@example.com user2@example.com user3@example.com )
for email in $emails; do
  for user in $usernames; do
    ${=httpie} POST http://localhost:9292/api/v1/user/new username="$user" email="$email" password='hunter2hunter2'
done
done

echo 'This creates 2 users without email addresses'
echo 'They should both work, and not return 409'
usernames=( no_email_1 no_email_2 )
for user in $usernames; do
  http -j --follow POST http://localhost:9292/api/v1/user/new username="$user" password='hunter2hunter2'
done

echo 'pp TcelferApi::User.map { {user: _1.username, email: _1.email} };' | bundle exec bin/console
