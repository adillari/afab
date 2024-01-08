# frozen_string_literal: true

require "bundler/setup"
require "discordrb"
require "open-uri"
require "json"
require "rufus-scheduler"
require_relative "modules/apod"

TOKEN = ENV["AFAB_TOKEN"]
NASA_APOD_API_KEY = ENV["NASA_APOD_API_KEY"]
CHANNEL = ENV["APOD_CHANNEL"]
DARK_RED = 0x9b1c16

bot = Discordrb::Bot.new(token: TOKEN)
scheduler = Rufus::Scheduler.new

bot.message(with_text: "!apod") do |event|
  msg_text, embed = APOD.create_embed
  event.channel.send_embed(msg_text, embed)
rescue StandardError => e
  channel.send_message("An error occurred: #{e.message}")
end

def send_apod(channel)
  msg_text, embed = APOD.create_embed
  channel.send_embed(msg_text, embed)
rescue StandardError => e
  channel.send_message("An error occurred: #{e.message}")
end

scheduler.cron("* 8 * * *") do
  channel = bot.channel(CHANNEL)
  send_apod(channel)
end

bot.run
scheduler.join
