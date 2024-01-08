# frozen_string_literal: true

module APOD
  class << self
    def create_embed
      embed = Discordrb::Webhooks::Embed.new
      msg_text = ""

      url = "https://api.nasa.gov/planetary/apod?api_key=#{NASA_APOD_API_KEY}"
      response = URI.open(url).read
      apod_data = JSON.parse(response)

      title = apod_data["title"]
      explanation = apod_data["explanation"]
      type = apod_data["media_type"]
      copyright = apod_data["copyright"]
      date = apod_data["date"]

      if type == "image"
        image_url = apod_data["url"]
      else
        msg_text = apod_data["url"]
      end

      footer = "APOD for #{date}"
      footer += " • #{type.capitalize} by #{copyright}" unless copyright.nil?

      embed.title = title
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: image_url) if type == "image"
      embed.description = explanation
      embed.color = DARK_RED
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer)

      [msg_text, embed]
    end
  end
end
