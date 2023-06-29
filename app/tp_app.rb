# frozen_string_literal: true

class TpApp < Sinatra::Base
  get '/rnd' do
    content_type 'application/json'

    num = MyApp.i.redis_pool.with do |r|
      r.get('tpa:d:rand')
    end

    MultiJson.dump({
      data: num,
      version: 'v2'
    })
  end
end
