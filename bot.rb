# frozen_string_literal: true

require "bundler/setup"
require "discordrb"
require "faraday"
require "json"
require "uri"
require "cgi"
require "rufus-scheduler"
require_relative "modules/apod"
require_relative "modules/link_cleaner"

TOKEN = ENV["AFAB_BOT_TOKEN"]
CHANNEL = ENV["APOD_CHANNEL"]

bot = Discordrb::Bot.new(token: TOKEN)
scheduler = Rufus::Scheduler.new

bot.message(contains: "http") do |event|
  return if event.message.from_bot?
  uris = event.message.content.scan(%r{https?://\S+}).map { |link| URI.parse(link) }
  cleaned_uris = LinkCleaner.clean_uris(uris)
  cleaned_uris.each do |uri|
    event.channel.send_message("Removed trackers from link:\n#{uri}", false, nil, nil, nil, event.message)
  end
end

bot.message(with_text: "!apod") do |event|
  channel = event.channel
  send_apod(channel)
end

def send_apod(channel)
  retries ||= 0

  msg_text, embed = APOD.create_embed
  channel.send_message(msg_text) unless msg_text == ""
  channel.send_embed("", embed)
rescue StandardError => e
  channel.send_message("An error occurred: #{e.message}\nRetrying...")

  sleep(10)
  retries += 1
  retry if retries < 3
end

scheduler.cron("0 8 * * *") do
  channel = bot.channel(CHANNEL)
  send_apod(channel)
end

at_exit { bot.stop }
bot.run
scheduler.join
