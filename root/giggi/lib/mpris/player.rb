#!/usr/bin/ruby
#
# MPRIS is the Media Player Remote Interfacing Specification.
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

class MPRIS

  # This class represents the player itself.
  class Player
  
    PLAYING = 0
    PAUSED = 1
    STOPPED = 2
    
    # A player object should only be created directly by its parent MPRIS
    def initialize( service, parent ) #:nodoc:
      @service = service
      @parent = parent
    
      # Check the service implements the MediaPlayer interface
      object = @service.object("/Player")
      object.introspect
      unless object.has_iface? MPRIS::MPRIS_INTERFACE
        raise(MPRIS::InterfaceNotImplementedException, 
          "#{@service.name} does not implement the MediaPlayer interface on /Player.")
      end
      @interface = object[MPRIS::MPRIS_INTERFACE]
    end
    
    
    # Goes to the next item in the TrackList.
    def next
      @interface.Next
    end
    
    # Goes to the previous item in the TrackList.
    def previous
      @interface.Prev
    end
    
    # If playing : pause. If paused : unpause.
    def pause
      @interface.Pause
    end
    
    # Stop playback.
    def stop
      @interface.Stop
    end
    
    # If playing : rewind to the beginning of current track, else : start playing.
    def play
      @interface.Play
    end
    
    # Gives all metadata available for the current item.
    # Metadata is returned as key,values pairs in a Hash.
    def metadata
      return @interface.GetMetadata.first
    end
    
    # Toggle the current track repeat.
    # true to repeat the current track, false to stop repeating.
    def repeat=(bool)
      raise(ArgumentError,"'bool' argument cannot be nil") if bool.nil?
      @interface.Repeat(bool)
    end
    
    # Returns the current repeat status.
    #
    #  true: repeat the current element.
    #  false: go to the next element once the current has finished playing.
    def repeat
      # Thrid integer in array is repeat status
      return @interface.GetStatus.first[2] == 1
    end
    
    # Return the playing status of "Media Player".
    # MPRIS::Player::PLAYING / MPRIS::Player::PAUSED / MPRIS::Player::STOPPED
    def status
      return @interface.GetStatus.first[0]
    end
    
    # Check if there is a next track, or at least something that equals to it 
    # (that is, the remote can call the 'Next' method on the interface, and 
    # expect something to happen.
    def can_go_next?
      return capability(0)
    end
    
    # Check if there is a previous track.
    def can_go_prev?
      return capability(1)
    end
    
    # Check if it is possible to pause. This might not always be possible, 
    # and is a hint for frontends as to what to indicate.
    def can_pause?
      return capability(2)
    end
    
    # Whether playback can currently be started. This might not be the case 
    # if e.g. the playlist is empty in a player, or similar conditions.
    def can_play?
      return capability(3)
    end
    
    # Whether seeking is possible with the currently played stream.
    def can_seek?
      return capability(4)
    end
    
    # Whether metadata can be acquired for the currently played stream/source.
    def can_provide_metadata?
      return capability(5)
    end
    
    # Whether the media player can hold a list of several items.
    def has_tracklist?
      return capability(6)
    end
    
    # Sets the volume (argument must be in [0;100])
    def volume=(vol)
      raise(ArgumentError,"'vol' argument cannot be nil") if vol.nil?
      raise(ArgumentError,"'vol' argument shuld be an integer value") unless vol.is_a?(Integer)
      raise(ArgumentError,"'vol' argument cannot be negative") if (vol<0)
      raise(ArgumentError,"'vol' argument cannot be greater than 100") if (vol>100)
      @interface.VolumeSet(vol)
    end
    
    # Returns the current volume (must be in [0;100])
    def volume
      return @interface.VolumeGet.first
    end
    
    # Sets the playing position (argument must be in [0;<track_length>] 
    # in milliseconds)
    def position=(time)
      raise(ArgumentError,"'time' argument cannot be nil") if time.nil?
      raise(ArgumentError,"'time' argument shuld be an integer value") unless time.is_a?(Integer)
      raise(ArgumentError,"'time' argyment cannot be negative") if (time<0)
      @interface.PositionSet(time)
    end
    
    # Returns the playing position (will be [0;<track_length>] in milliseconds).
    def position
      return @interface.PositionGet.first
    end
  
    private

    # Hack so that tracklist can access our interface
    def interface
      return @interface
    end
    
    # Return the specified bit value from the capabilties bitfield
    def capability(bit)
      # FIXME: cache capabilities (for a short period)
      return ((@interface.GetCaps.first >> bit) & 0x01) == 0x01
    end

  end

end