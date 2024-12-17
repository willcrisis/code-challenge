require_relative 'google_old_parser'

module Parsers
  class GoogleParser < GoogleOldParser
    def results
      {
        'artworks' => extract_artworks.map { |artwork| parse_artwork(artwork) }
      }
    end

    private

    def extract_artworks
      document.at('g-loading-icon')
        .parent
        .children[1]
        .children
    end

    def parse_artwork(artwork)
      parsed_artwork = {
        'name' => artwork.at('div').xpath('div[1]').text,
        'link' => "#{GoogleOldParser::BASE_URL}#{artwork.at('a').attr('href')}",
        'image' => find_artwork_image_data(artwork.at('img').attr('id')),
      }

      extensions = artwork.at('div').xpath('div[2]').text
      parsed_artwork['extensions'] = [extensions] if extensions&.size > 0

      parsed_artwork
    end

    def find_artwork_image_data(img_id)
      script = image_replacement_script(img_id)
      return unless script

      token = script.content.split("var s='")[1]
      token.split("';var ii")[0].gsub('\\', '')
    end

    def image_replacement_script(img_id)
      if @image_replacement_scripts.nil?
        scripts = document.css('script')
        @image_replacement_scripts = scripts.select { |script| script.text.include?('_setImagesSrc') }
      end

      return unless img_id

      @image_replacement_scripts.find { |script| script.content.include?(img_id) }
    end
  end
end