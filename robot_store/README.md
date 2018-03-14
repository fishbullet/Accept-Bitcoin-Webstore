<p align="center"><img src="assets/store.png" width="360"></p>

Example of Webstore Rails application.

## Setup

1. `bundle install`
2. `bundle exec rake db:create`
3. `bundle exec rake db:migrate`
4. `bundle exec rake db:seed`

## Run

Run Rails server:
 
```bash
bundle exec rails server
```

Run rake task to check payments:

```bash
# In order to run than task every hour|minute|second
# use cron jobs
# or systemd timers
bundle exec rake pull_payments
```


