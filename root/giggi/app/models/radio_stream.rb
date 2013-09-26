require 'net/http'
require 'rexml/document'

XSPF_URL='http://radio.aelius.com/streams.xspf'

class RadioStream < ActiveRecord::Base

  def self.fetch
    url = URI.parse(XSPF_URL)
    res = Net::HTTP.start(url.host, url.port) {|http| http.get(url.path) }
    res.value # Raises HTTP error if the response is not 2xx.
    
    # Parse the server response
    doc = REXML::Document.new(res.body)

    # Add the new radio streams
    doc.elements.each("/playlist/trackList/track") do |track|
      stream = RadioStream.find_or_initialize_by_location( track.text('location') )
      stream.update_attributes(
        :title => track.text('title'),
        :creator => track.text('creator'),
        :annotation => track.text('annotation')
      )
    end
    
    # Delete all streams that haven't been updated recently
    # FIXME: implement this
    
  end
  
end
