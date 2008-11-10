#!/usr/bin/ruby
#
# MPRIS is the Media Player Remote Interfacing Specification.
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

class MPRIS

  # This class represents the Media Player's tracklist.
  #
  # Note that if player.has_tracklist? is false, the methods described below
  # will be implemented as no-ops, except metadata (which is valid only if given 
  # argument is 0), current_track (which always returns 0), 
  # length (which will return 0 or 1), and add_track.
  #
  class TrackList
  
    # A tracklist object should only be created directly by its parent MPRIS
    def initialize( service, parent ) #:nodoc:
      @service = service
      @parent = parent
    
      # Check the service implements the MediaPlayer interface
      object = @service.object("/TrackList")
      object.introspect
      unless object.has_iface? MPRIS::MPRIS_INTERFACE
        raise(MPRIS::InterfaceNotImplementedException, 
          "#{@service.name} does not implement the MediaPlayer interface on /TrackList.")
      end
      @interface = object[MPRIS::MPRIS_INTERFACE]
    end
    
    # Gives all metadata available for item at given position in the TrackList, counting from 0.
    # 
    # Metadata is returned as key,values pairs in a Hash
    #
    # The pos argument is the position in the TrackList of the item of which the metadata is requested.
    def metadata(pos)
      raise(ArgumentError,"'pos' argument cannot be nil") if pos.nil?
      return @interface.GetMetadata(pos).first
    end
  
    # Return the position of current URI in the TrackList The return value is zero-based, 
    # so the position of the first URI in the TrackList is 0. The behavior of this method is 
    # unspecified if there are zero items in the TrackList.
    def current_track
      return @interface.GetCurrentTrack.first
    end
  
    # Returns the number of items in the TrackList.
    def length
      return @interface.GetLength.first
    end
  
    # Appends an URI in the TrackList.
    #
    # Returns 0 if successful
    def add_track(uri,play_immediately=false)
      raise(ArgumentError,"'uri' argument cannot be nil") if uri.nil?
      @interface.AddTrack(uri,play_immediately)
    end
  
    # Removes an URI from the TrackList.
    #
    # pos is the position in the tracklist of the item to remove.
    def delete_track(pos)
      raise(ArgumentError,"'pos' argument cannot be nil") if pos.nil?
      @interface.DelTrack(pos)
    end

    # Removes all tracks from the TrackList.
    def delete_all
      len = length
      while(len) do
        delete_track(0)
        len -= 1
      end
    end
  
    # Set the tracklist looping status. true to loop, false to stop looping.
    def loop=(bool)
      raise(ArgumentError,"'bool' argument cannot be nil") if bool.nil?
      @interface.SetLoop(bool)
    end
    
    # Returns tracklist looping status.
    def loop
      # Hack to get the player interface
      player_iface = @parent.player.send(:interface)
      # Fourth integrer in array is the looping status
      return player_iface.GetStatus.first[3] #== 1
    end
  
    # Set the tracklist shuffle / random status. It may or may not play tracks only once.
    # true to play randomly / shuffle tracklist, false to play normally / reorder tracklist.
    def random=(bool)
      raise(ArgumentError,"'bool' argument cannot be nil") if bool.nil?
      @interface.SetRandom(bool)
    end
    
    # Returns the tracklist shuffle / random status.
    def random
      # Hack to get the player interface
      player_iface = @parent.player.send(:interface)
      # Second integrer in array is the random status
      return player_iface.GetStatus.first[1] #== 1
    end

  end

end
