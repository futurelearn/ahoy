module Ahoy
  module Deckhands
    class TrafficSourceDeckhand
      def initialize(referrer)
        @referrer = referrer
      end

      def referring_domain
        @referring_domain ||= Addressable::URI.parse(@referrer).host.first(255) rescue nil
      end

      def search_keyword
        # puts @referrer.inspect
        # puts @referrer.encoding.inspect
        # puts self.class.referrer_parser.parse(@referrer)[:term][0..255]
        # @search_keyword ||= (self.class.referrer_parser.parse(@referrer)[:term][0..255] rescue nil).presence
        
        begin
          parsed_referrer = self.class.referrer_parser.parse(@referrer)[:term][0..255]
          cleaned_parsed_referrer = parsed_referrer.encode(invalid: :replace, replace: "\uFFFD")
          @search_keyword ||= (cleaned_parsed_referrer).presence
        rescue
          nil
        end
        
        # puts "referrer is: #{ @referrer.nil? ? 'nil' : @referrer }"
        # parsed_referrer = self.class.referrer_parser.parse(@referrer)[:term][0..255] rescue nil
        # cleaned_parsed_referrer = parsed_referrer.encode(invalid: :replace, replace: "\uFFFD") # rescue nil
        # puts "HELLO FROM CODE #{parsed_referrer}"
        # puts "HELLO FROM CODE #{cleaned_parsed_referrer}"
        # @search_keyword ||= (cleaned_parsed_referrer).presence
      end

      # performance hack for referer-parser
      def self.referrer_parser
        @referrer_parser ||= RefererParser::Parser.new
      end
    end
  end
end
