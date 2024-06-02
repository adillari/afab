# frozen_string_literal: true

require "uri"
require "cgi"

module LinkCleaner
  TRACKER_PARAMS = [
    'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
    'gclid', 'fbclid', 'si', 's', 'fbid',
    'trk', 'source', "ei", "iflsig", "ved", "uact", "oq", "gs_lp", "sclient", 
  ]

  class << self
    def has_tracker?(link)
      uri = URI.parse(link)
      query_params = CGI.parse(uri.query || '')
      (query_params.keys & TRACKER_PARAMS).any?
    end

    def clean(link)

    end
  end
end
