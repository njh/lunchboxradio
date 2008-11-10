#!/usr/bin/ruby
#
# MPRIS is the Media Player Remote Interfacing Specification.
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

require 'dbus'
require 'mpris/player'
require 'mpris/tracklist'


# This is the base MPRIS class. It creates the #Player and #Tracklist objects 
# automatically, which are accessible via the attribute readers.
class MPRIS
  attr_reader :player
  attr_reader :tracklist

  MPRIS_SERVICE_PREFIX = 'org.mpris'
  MPRIS_INTERFACE = 'org.freedesktop.MediaPlayer'
  
  # Create a new MPRIS instance. 
  # By default it will return the first MPRIS enabled player found 
  # on the Session Bus.
  #
  # The dbus_address parameter can be use to specify a different dbus, for 
  # example 'unix:path=/var/run/dbus_socket'.
  #
  # The service_name parameter can be used to specify a specifc MediaPlayer,
  # for example 'org.mpris.vlc'.
  def initialize( dbus_address=nil, service_name=nil )

    # FIXME: support passing in a dbus object, instead of a dbus address
    if dbus_address.nil?
      # Use the default session bus
      @dbus = DBus::SessionBus.instance
    else
      @dbus = DBus::Connection.new(dbus_address)
      @dbus.connect
      @dbus.send_hello
    end
    
    # Look for service name, if one isn't given
    if service_name.nil?
      service_names = @dbus.proxy.ListNames[0]
      service_names.each { |n|
        if (n =~ /^org.mpris/)
          service_name = n
          break
        end
      }
      
      # Did we find one?
      if service_name.nil?
        raise( ServiceNotFoundException, "No MPRIS service found on D-Bus." )
      end
    end
    
    # Get the service
    @service = @dbus.service(service_name)
    if @service.nil?
      raise( ServiceNotFoundException, "MPRIS service '#{service_name}' not found on D-Bus." )
    end
    
    # Check the service implements the MediaPlayer interface
    root_object = @service.object("/")
    root_object.introspect
    unless root_object.has_iface? MPRIS_INTERFACE
      raise(InterfaceNotImplementedException, 
        "#{@service.name} does not implement the MediaPlayer interface on /." )
    end
    @interface = root_object[MPRIS_INTERFACE]
    
    # Create the player object
    @player = MPRIS::Player.new(@service, self)
    
    # Create a tracklist object
    @tracklist = MPRIS::TrackList.new(@service, self)
  end

  def inspect # :nodoc:
    return %Q(#<MPRIS: local_name="#{@dbus.unique_name}", remote_name="#{@service.name}">)
  end
  
  # Identify the "media player" as in "VLC 0.9.0", "bmpx 0.34.9", "Audacious 1.4.0" ...
  #
  # Returns a string containing the media player identification.
  def identity
    return @interface.Identity
  end
  
  # Makes the "Media Player" exit.
  def quit
    @interface.Quit
  end
  
  # Returns the version of the MPRIS spec being implemented as major.major
  def mpris_version
    return @interface.MprisVersion.first.join('.')
  end
 
 
  # Exception raised if no MPRIS service is found on the D-Bus.
  class ServiceNotFoundException < Exception
  end
 
  # Exception raised if MediaPlayer interface isn't implemented.
  class InterfaceNotImplementedException < Exception
  end

end
