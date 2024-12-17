require_relative 'base_parser'

module Parsers
  class GoogleOldParser < BaseParser
    BASE_URL = 'https://www.google.com'.freeze

    def results
      {
        'artworks' => extract_artworks.map { |artwork| parse_artwork(artwork) }
      }
    end

    private

    def extract_artworks
      document.at('g-scrolling-carousel')
        .at('div')
        .at('div')
        .children
    end

    def parse_artwork(artwork)
      parsed_artwork = {
        'name' => artwork.css('span').text,
        'link' => "#{BASE_URL}#{artwork.at('a').attr('href')}",
        'image' => find_artwork_image_data(artwork),
      }

      extensions = artwork.at('a').xpath('div[2]/div[2]')&.children.map(&:text)
      parsed_artwork['extensions'] = extensions if extensions.any?

      parsed_artwork
    end

    def find_artwork_image_data(artwork)
      artwork_image = document_image_map.find { |image| artwork.at('img').attr('id') == image[:id] }
      artwork_image[:image] if artwork_image
    end

    def document_image_map
      return @document_image_map if @document_image_map
      
      tokens = image_replacement_script.content.split("var s='")
      tokens.shift
      @document_image_map = tokens.map { |token| parse_image_token(token) }
    end

    def parse_image_token(token)
      image, rest = token.split("';var ii=['")
      id = rest.split("'];")[0]
      { id: id, image: image.gsub('\\', '') }
    end

    def image_replacement_script
      return @image_replacement_script if @image_replacement_script
      
      scripts = document.css('script')
      @image_replacement_script = scripts.find { |script| script.text.include?('_setImagesSrc') }
    end
  end
end