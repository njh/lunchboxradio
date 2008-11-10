#!/usr/bin/ruby
#

$:.unshift File.dirname( File.expand_path(__FILE__) )
$:.unshift File.dirname( File.expand_path(__FILE__) )+'/lib'

require 'xspf'
require 'mpris'
require 'audio-mixer'
require 'open-uri'
require 'glk'
require 'pp'

LCD_SERIAL_PORT='/dev/ttyUSB0'
XSPF_URL='http://radio.aelius.com/streams.xspf'


# Open connection to the LCD screen
$glk = Device::MatrixOrbital::GLK.new(LCD_SERIAL_PORT)
$glk.set_font(1)
$glk.set_autoscroll_off
$glk.clear_screen


# Quick hack to get IP address
def get_ip_address
  IO.popen("ifconfig") do |io|
    while line = io.gets
      return $1 if (line =~ /inet addr:([\d\.]+)/ and $1 != '127.0.0.1')
    end
  end
  return nil
end

# Quick hack to get IP address
def get_mac_address
  IO.popen("ifconfig") do |io|
    while line = io.gets
     return $1 if (line =~ /HWaddr ([A-Z0-9:]+)/)
    end
  end
  return nil
end

def change_stream
  # Stop playing the previous stream
  $mpris.player.stop
  
  # Make sure that we stay within range
  total = $xspf.playlist.tracklist.tracks.size
  if ($current < 0)
    $current = total-1
  elsif ($current >= total)
    $current = 0
  end

  # Get the currently selected stream
  track = $xspf.playlist.tracklist.tracks[$current]
  
  # remove the old stream and add the new one
  $mpris.tracklist.delete_track(0)
  $mpris.tracklist.add_track( track.location, true )

  # Display what is playing
  $glk.draw_solid_rect( 0, 0, 0, 192, 7 )
  $glk.draw_line( 0, 7, 192, 7 )
  $glk.set_cursor_coordinate( 0, 0 )
	$glk.puts_console "#{$current+1}. #{track.title}".slice(0,40)
end


def display_volume
  $glk.draw_line( 0, 55, 192, 55 )
  $glk.draw_solid_rect( 0, 0, 56, 192, 64 )
  $glk.set_cursor_coordinate( 0, 57 )
  $glk.puts_console "Volume: #{$am.volume}"
end

def display_clock
  time = Time.now.strftime("%Y-%m-%d %H:%M:%S") # 19 chars
  $glk.set_cursor_coordinate( 112, 57 )
  $glk.puts time
end

def button_press(ch)

  puts "Got button press: "+format("0x%x",ch)

  case ch
    when 72 then
      $glk.set_cursor_coordinate( 0, 28 )
      $glk.puts_console "My IP Address is: #{get_ip_address}"
      $glk.puts_console "My MAC Address is: #{get_mac_address}"
    when 67 then
      puts "Going next"
      $current += 1
      change_stream
    when 68 then
      puts "Going previous"
      $current -= 1
      change_stream
    when 69 then
      if $mpris.player.status == MPRIS::Player::PLAYING
        $glk.set_cursor_coordinate( 0, 28 )
        $glk.puts_console "Stopping playback"
        $mpris.player.stop
      else
        $glk.set_cursor_coordinate( 0, 28 )
        $glk.puts_console "Resuming playback"
        $mpris.player.play
      end
    when 65 then
      $am.volume_up
      display_volume
    when 71 then
      $am.volume_down
      display_volume
    when 66 then
      $glk.clear_screen
      $glk.puts_console "Resetting..."
      exit
    else
      puts "Don't know how to handle: "+format("0x%x",ch)
  end
  
end


## Wrap the rest of the script up in an exection handler
begin

  # Create audio mixer object
  $am = AudioMixer.new
  
  ## Load list of streams available on server
  $glk.puts_console "Downloading stream list..."
  $glk.puts_console "URL: #{XSPF_URL}"

  # Open the XSPF list of streams
  open(XSPF_URL) do |file|
    # Fetch the document
    xspf_data = file.readlines.join
    
    # Parse the document
    $xspf = XSPF.new(xspf_data)
  end

  # Display the number of steams we found
  $glk.puts_console "Found #{$xspf.playlist.tracklist.tracks.size} streams."
  sleep 0.5
  $glk.clear_screen
  
  ## Connect to VLC
  $mpris = MPRIS.new('unix:path=/var/run/dbus.socket')
  
  # Enable repeat (restart streams)
  $mpris.player.repeat = true
  $mpris.tracklist.loop = true
  
  # Start playing the first stream
  $current = 0
  change_stream
  
  # Update the screen
  display_volume
  
  # Loop forever
  while true do
    # Update the clock
    display_clock

    # Any data waiting to be read?
    unless IO.select([$glk], nil, nil, 1.0).nil?
      button_press( $glk.getc )
    end
  end


rescue => exception
  # Something very bad happened
  $glk.puts_console "Fatal error: #{exception}"
  $stderr.print exception.backtrace.join("\n")

  # Sleep to prevent respawning too fast
  sleep 5
end


