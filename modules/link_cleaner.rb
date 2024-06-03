# frozen_string_literal: true

module LinkCleaner
  TRACKER_PARAMS = [
    "utm_source",
    "utm_medium",
    "utm_campaign",
    "utm_term",
    "utm_content",
    "igsh",
    "gclid",
    "fbclid",
    "si",
    "s",
    "fbid",
    "trk",
    "source",
    "ei",
    "iflsig",
    "ved",
    "uact",
    "oq",
    "gs_lp",
    "sclient",
  ]

  class << self
    def clean_uris(uris)
      uris.filter! { |uri| has_tracker?(uri) }
      uris.map { |uri| clean(uri) }
    end

    private

    def has_tracker?(uri)
      query_params = CGI.parse(uri.query || "")
      return true if twitter?(uri) && query_params.keys.include?("t")

      query_params.keys.intersect?(TRACKER_PARAMS)
    end

    def clean(uri)
      query_params = CGI.parse(uri.query || "")
      query_params.delete("t") if twitter?(uri)
      TRACKER_PARAMS.each { |param| query_params.delete(param) }
      uri.query = URI.encode_www_form(query_params)
      uri.to_s
    end

    def twitter?(uri)
      ["twitter.com", "t.co", "x.com"].include?(uri.host.downcase)
    end
  end
end
