require 'rubygems'
require 'httparty'
require 'cgi'

class Yahoo
  include HTTParty

  class << self
    attr_accessor :apikey
  end

  format :xml
  base_uri "local.yahooapis.com"

  class << self
    def geocode(opts={})
      opts[:appid] = self.apikey

      data = query(opts)
      result = data['ResultSet']['Result'] rescue nil
      result = result.is_a?(Array) ? result[0] : result

      {
        :latitude => result['Latitude'],
        :longitude => result['Longitude']
      } rescue {}
    end

    def query(opts)
      data = get('/MapsService/V1/geocode', :query => escaped(opts))
    end

    def escaped(opts)
      out = {}
      opts.each do |k,v|
        out[k] = CGI::escape(v) unless v.blank?
      end
      out
    end
  end
end
