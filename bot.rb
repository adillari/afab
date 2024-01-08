# frozen_string_literal: true

require "bundler/setup"
require "discordrb"
require "faraday"
require "json"
require "rufus-scheduler"
require_relative "modules/apod"

TOKEN = ENV["AFAB_BOT_TOKEN"]
NASA_APOD_API_KEY = ENV["NASA_APOD_API_KEY"]
CHANNEL = ENV["APOD_CHANNEL"]
DARK_RED = 0x9b1c16

bot = Discordrb::Bot.new(token: TOKEN)
scheduler = Rufus::Scheduler.new

bot.message(with_text: "!apod") do |event|
  channel = event.channel
  send_apod(channel)
end

def send_apod(channel)
  retries ||= 0

  msg_text, embed = APOD.create_embed
  channel.send_embed(msg_text, embed)
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

bot.run
scheduler.join
