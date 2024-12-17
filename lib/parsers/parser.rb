require 'nokogiri'
require_relative 'google_parser'

PROVIDER_MAP = {
  google: Parsers::GoogleParser
}

module Parsers
  class Parser
    attr_reader :provider

    def initialize(content, provider = 'google')
      raise 'Provider not implemented' unless PROVIDER_MAP[provider.to_sym]
      @provider = PROVIDER_MAP[provider.to_sym].new(content)
    end

    def results
      provider.results
    end

    def to_json
      results.to_json
    end
  end
end