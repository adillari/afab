# frozen_string_literal: true

require "bundler/setup"
require "discordrb"
require "open-uri"
require "json"
require "rufus-scheduler"

TOKEN = ENV["AFAB_TOKEN"]
NASA_APOD_API_KEY = ENV["NASA_APOD_API_KEY"]
CHANNEL = ENV["APOD_CHANNEL"]
DARK_RED = 0x9b1c16

bot = Discordrb::Bot.new(token: TOKEN)
scheduler = Rufus::Scheduler.new

def send_apod(channel)
  url = "https://api.nasa.gov/planetary/apod?api_key=#{NASA_APOD_API_KEY}"
  response = URI.open(url).read
  apod_data = JSON.parse(response)

  title = apod_data["title"]
  explanation = apod_data["explanation"]

  type = apod_data["media_type"]
  if type == "image"
    image_url = apod_data["url"]
  else
    channel.send_message(apod_data["url"])
  end

  footer = "APOD for #{apod_data["date"]}"
  footer += " • #{type.capitalize} by #{apod_data["copyright"]}" unless apod_data["copyright"].nil?

  channel.send_embed do |embed|
    embed.title = title
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: image_url) if type == "image"
    embed.description = explanation
    embed.color = DARK_RED
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer)
  end
rescue StandardError => e
  channel.send_message("An error occurred: #{e.message}")
end

scheduler.cron("* 8 * * *") do
  channel = bot.channel(CHANNEL)
  send_apod(channel)
end

bot.run
scheduler.join
