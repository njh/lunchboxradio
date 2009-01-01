#!/usr/bin/ruby



class AudioMixer
  attr_reader :iface, :volume, :min_volume, :max_volume

  def initialize(iface="'PCM',0")
    @iface = iface
    
    # Set some sane defaults
    @volume = 0
    @min_volume = 0
    @max_volume = 31

    # Get the current volume
    IO.popen("amixer sget #{@iface}") { |f|
      while line = f.gets do
        if (line =~ /Limits: Playback (\d+) - (\d+)/)
          @min_volume = $1.to_i
          @max_volume = $2.to_i
        elsif (line =~ /Front Left: Playback (\d+)/)
          @volume = $1.to_i
        end
       end
    }
   
    # Got volume ok?
    #raise "Failed to get current audio mixer volume" if @volume.nil?
    
    # Getting the volume from the USB device appears to be broken, 
    # set it to a default value instead
    self.volume = 8
  end
  
  
  def volume=(volume)
    volume = volume.to_i
    volume = @max_volume if (volume > @max_volume)
    volume = @min_volume if (volume < @min_volume)
    system("amixer -q sset #{@iface} #{volume}") or
      raise "Failed to set audio mixer volume"
    @volume = volume
  end

  def volume_up
    self.volume += (@max_volume - @min_volume) / 16
  end

  def volume_down
    self.volume -= (@max_volume - @min_volume) / 16
  end
  
end

