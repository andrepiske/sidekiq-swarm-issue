# frozen_string_literal: true

# class Worker::TpRandomizer < Rjob::Worker
class Worker::TpRandomizer
  include Sidekiq::Job

  def perform
    num = rand((1..10000)) + 100000
    puts "New number: #{num}"

    wait_time = Integer(ENV.fetch('TP_WAIT_FOR', '5'))
    puts "Waiting #{wait_time} before setting number"
    tp_wait_for(wait_time)
    puts "Done waiting!"

    MyApp.i.redis_pool.with do |r|
      r.set('tpa:d:rand', num.to_s)
    end
  end

  def self.retry_options
    { retry: false }
  end

  def tp_wait_for(wait_secs)
    expires_at = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) + wait_secs
    remaining = 1
    while remaining > 0.3
      sleep 0.3
      remaining = expires_at - ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    end
  end
end
