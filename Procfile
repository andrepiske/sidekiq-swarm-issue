web: bundle exec puma -b tcp://0.0.0.0:$PORT -e $RACK_ENV -t $PUMA_THREADS -v

# To use sidekiq without Swarm:
# skiq: bundle exec sidekiq -C config/sidekiq.yml -r ./config/boot.rb

# To use sidekiq with Swarm:
skiq: SIDEKIQ_PRELOAD= SIDEKIQ_COUNT=${SIDEKIQ_COUNT_WORKER:-2} bundle exec sidekiqswarm -C config/sidekiq.yml -r ./config/boot.rb
