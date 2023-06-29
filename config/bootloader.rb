# frozen_string_literal: true

# If using sinatra
require 'grande/use_sinatra'
# If using redis
require 'grande/use_redis'

require 'grande/with_config_loader'

require 'sidekiq/pro/expiry'

class MyApp
  attr_reader :env
  attr_reader :logger

  def with_config_loader
    config_path = File.join(Grande.c.app.root_path, 'config/config.yml')
    config_payload = File.read(config_path)

    @config_loader = Comff.new(config_payload)

    yield
  ensure
    @config_loader = nil
  end

  include Grande::UseRedis

  def self.l
    i.logger
  end

  def self.i
    @instance ||= new
  end

  def self.instance
    i
  end

  def root_path
    File.expand_path('..', __dir__)
  end

  attr_reader :redis_pool

  def boot!
    raise "Application boot already began (status is '#{@boot}')" if booting? || booted?
    @boot = :booting

    @logger = ::Logger.new(STDOUT)
    @env = ENV['RACK_ENV']
    logger.info("Booting app with Grande in #{@env} environment")

    Grande.c.set_app(self)

    with_config_loader do
      redis_url = @config_loader.get_str!('redis.url')
      @redis_pool = ConnectionPool.new(size: @config_loader.get_int!('redis.pool.size')) do
        Redis.new(url: redis_url)
      end

      setup_sidekiq(redis_url)
    end

    @boot = :booted
  end

  def booting?; @boot == :booting; end
  def booted?; @boot == :booted; end

  def setup_sidekiq(redis_url)
    Sidekiq::Client.reliable_push!

    Sidekiq.configure_client do |config|
      config.redis = { url: redis_url }
      config.logger = Logger.new($stdout, level: :debug)
    end

    Sidekiq.configure_server do |config|
      config.redis = { url: redis_url }
      config.logger = Logger.new($stdout, level: :debug)
      config.super_fetch!
      config.reliable_scheduler!

      config.periodic do |mgr|
        mgr.register("* * * * *", 'Worker::TpRandomizer', scheduled: true)
      end
    end
  end

  def setup_db_connections
    setup_redis_connection if respond_to?(:setup_redis_connection)
  end

  def restore_db_connections_after_fork
    with_config_loader { setup_db_connections }
  end
end
