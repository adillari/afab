require 'discordrb'
require 'sidekiq'
require_relative 'constants'

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

bot = Discordrb::Bot.new(token: BOT_TOKEN)

# register onready event
bot.ready do
  puts 'Bot started successfully'
end

bot.message(with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

require './sk_worker'

bot.message(with_text: 'sk_test') do |event|
  event.respond("trying to start sidekiq job #{event.user.username}.")

  SkWorker.perform_async
  SkWorker.perform

  puts 'done w/ sidekiq job'
end

bot.run
