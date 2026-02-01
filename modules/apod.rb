# frozen_string_literal: true

module APOD
  API_KEY = ENV["NASA_APOD_API_KEY"]
  DARK_RED = 0x9b1c16

  class << self
    def json
      url = "https://api.nasa.gov/planetary/apod"
      response = Faraday.get(url, api_key: API_KEY)

      raise "API request failed" unless response.success?

      JSON.parse(response.body)
    end

    def create_embed
      apod_data = json

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
      if type == "image"
        =begin
        filename = "#{Time.now.to_s.split.first}.#{image_url.split(".").last}"
        filepath = "/var/www/assets/#{filename}"

        URI.open(URI.parse(image_url)) do |image|
          File.open(filepath, "wb") { |file| file.write(image.read) }
        end

        embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://assets.maz.dev/#{filename}")
        =end
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: image_url)
      end
      embed.description = explanation
      embed.color = DARK_RED
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer)

      msg_text ||= nil
      [msg_text, embed]
    end
  end
end
