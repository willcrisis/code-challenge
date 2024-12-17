module Parsers
  class BaseParser
    attr_reader :document
    
    def initialize(content)
      @document = Nokogiri::HTML(content)
    end

    def results
      raise 'Not implemented'
    end
  end
end