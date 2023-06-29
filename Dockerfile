FROM ruby:3.2.2-slim-bullseye AS rb
  WORKDIR /app
  ENV BUNDLE_APP_CONFIG=/app/bundle

  RUN apt-get update -y ; \
      apt-get install -y build-essential ; \
      rm -rf /var/lib/apt/lists/*

  RUN gem update --system ; \
      gem install bundler

  RUN bundle config set --local path /app/bundle/vendor ; \
      bundle config set --local without 'development test' ; \
      bundle config set --local deployment 'true'

  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock

  ARG BUNDLE_ENTERPRISE__CONTRIBSYS__COM
  RUN bundle install -j8

FROM ruby:3.2.2-slim-bullseye AS files
  WORKDIR /app

  COPY --chown=1001:1001 . /app
  COPY --chown=1001:1001 config config
  COPY --chown=1001:1001 app app
  COPY --chown=1001:1001 config.ru config.ru
  COPY --chown=1001:1001 script script

  RUN rm -Rf .git .gitignore

FROM ruby:3.2.2-slim-bullseye
  WORKDIR /app

  RUN apt-get update -y && \
    apt-get install -y curl && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

  RUN gem update --system ; \
      gem install bundler

  USER 1001:1001

  RUN bundle config set --local path /app/bundle/vendor ; \
      bundle config set --local without 'development test' ; \
      bundle config set --local deployment 'true'

  COPY --from=files /app /app
  COPY --from=rb --chown=1001:1001 /app/bundle /app/bundle

  ENV RACK_ENV=production
  ENV PUMA_THREADS=4:32
  ENV PORT=8080
  EXPOSE $PORT

  ENTRYPOINT ["/app/script/entrypoint"]
