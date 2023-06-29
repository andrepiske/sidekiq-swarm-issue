
Deploy to heroku (using Heroku CLI):

First you need to login to heroku registry:
```
heroku login
heroku container:login
```

Then deploy the app with:

```
docker build . -t swarm-issue:latest --build-arg BUNDLE_ENTERPRISE__CONTRIBSYS__COM="<your-sidekiq-ent-license-key>"
heroku container:push -a <the-app-name> --recursive
heroku container:release -a <the-app-name> web skiq
```

To run this, the following env vars are mandatory:

- `REDIS_URL` - redis shared between Sidekiq and the app itself
- `BUNDLE_ENTERPRISE__CONTRIBSYS__COM` - sidekiq pro/ent key

To run this, the `REDIS_URL` env var must be set. Default value of localhost
will be picked up from `config/config.yml` otherwise.

To open a console in Heroku:

```
heroku run /bin/bash -a <the-app-name>
# Then:
irb -r ./config/boot.rb
```

