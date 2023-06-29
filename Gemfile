# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'grande'
gem 'comff'

# gem 'sidekiq', '6.5.9'
gem 'sidekiq', '~> 7.1.2'

# Sidekiq pro & enterprise
source 'https://enterprise.contribsys.com/' do
  gem 'sidekiq-ent'
  gem 'sidekiq-pro'
end

gem 'sinatra'
gem 'sinatra-contrib'
gem 'oj'
gem 'multi_json'
gem 'redis'
gem 'connection_pool'
gem 'rake'
gem 'puma'
gem 'racksh'
gem 'zeitwerk'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end
