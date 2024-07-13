# frozen_string_literal: true

module APOD
  API_KEY = ENV["NASA_APOD_API_KEY"]
  DARK_RED = 0x9b1c16

  class << self
    def create_embed
      url = "https://api.nasa.gov/planetary/apod"
      response = Faraday.get(url, api_key: API_KEY)

      raise "API request failed" unless response.success?

      apod_data = JSON.parse(response.body)

      title       = apod_data["title"]
      explanation = apod_data["explanation"]
      type        = apod_data["media_type"]
      copyright   = apod_data["copyright"]
      date        = apod_data["date"]

      if type == "image"
        image_url = apod_data["url"]
      else
        msg_text = apod_data["url"]
      end

      footer = "APOD for #{date}"
      footer += " • #{type.capitalize} by #{copyright}" unless copyright.nil?

      embed = Discordrb::Webhooks::Embed.new
      embed.title = title
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: image_url) if type == "image"
      embed.description = explanation
      embed.color = DARK_RED
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer)

      msg_text ||= nil
      [msg_text, embed]
    end
  end
end
