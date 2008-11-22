#!/usr/bin/ruby
#
# Script to display the URI, artist and title for the tracks on the tracklist.
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

$:.unshift File.dirname(__FILE__)+'/lib'

require 'mpris'

mpris = MPRIS.new('unix:path=/var/run/dbus.socket')

# Get the number of tracks on the tracklist
len = mpris.tracklist.length
if (len <= 0)
  puts "There are no tracks on the tracklist."

else 

  # Get the number of the currently playing track
  current = mpris.tracklist.current_track
  
  i=0
  while (i<len) do
  
    # Print asterisk next to currently playing track
    if (i==current)
      print "* "
    else
      print "  "
    end
    
    # There is a bug in VLC, which makes tracklist start at 1
    meta = mpris.tracklist.metadata(i+1)
    puts "#{i}: #{meta['URI']} (#{meta['artist']} - #{meta['title']})"
    i+=1
  end

end
