#!/usr/bin/ruby

require 'network-interface'


class WirelessNetwork
  attr_accessor :ap, :essid, :mode, :channel, :quality
  attr_accessor :signal, :noise, :encryption, :standard
end


class WirelessInterface < NetworkInterface

  def initialize

    interfaces = Array.new
    # Open up the wireless interface list and parse each line
    file = File.new('/proc/net/wireless', 'r')
    while (line = file.gets)
      if (line =~ /^\s+(\w+\d):/) then
        interfaces << $1
      end
    end
    file.close
    
    raise "Didn't find any wireless interfaces." if interfaces.size == 0
    $stderr.puts "Warning: Found more than one wireless interface." if interfaces.size > 1
    
    @name = interfaces.first
  end
  
  def standard=(standard)
    map = {
      'auto' => 0,
      '802.11a' => 1,
      '802.11b' => 2,
      '802.11g' => 3,
    }
    
    mode = map[standard]
    raise "Unknown wireless standard: #{standard}" if mode.nil?
    
    puts "  Setting standard=#{standard}"
    system('iwpriv', @name, 'mode', mode.to_s) or 
    raise("Failed to switch to #{standard} mode.");
  end
  
  def essid=(essid)
    puts "  Setting essid=#{essid}"
    system('iwconfig', @name, 'essid', essid) or 
    raise("Failed to set ESSID to #{essid}.");
  end

  def channel=(channel)
    puts "  Setting channel=#{channel}"
    system('iwconfig', @name, 'channel', channel) or 
    raise("Failed to set Channel to #{channel}.");
  end
  
  def mode=(mode)
    puts "  Setting mode=#{mode}"
    system('iwconfig', @name, 'mode', mode) or 
    raise("Failed to switch to mode #{mode}.");
  end
  
  def wep_key=(wep_key)
    unless wep_key.nil?
      puts "  Setting wep_key=#{wep_key}"
      system('iwconfig', @name, 'key', wep_key) or 
      raise("Failed to set encryption key to #{key}.");
    end
  end
  
  def scan_networks
    blocks = []
  
    # Perform network scan
    IO.popen("iwlist #{@name} scan 2>/dev/null") { |f|
      lines = f.readlines.join
      blocks = lines.split(/Cell \d+ -/)
      blocks.shift # ignore the first result
    }
  
    networks = []
    for block in blocks
      network = WirelessNetwork.new
      if (block =~ /(Address|Access point):\s*([\w:]+)/i)
        network.ap = $2
      end
      if (block =~ /ESSID:\s*\"(.*?)\"/i)
        network.essid = $1
      end
      next if (network.essid=="" or network.essid.nil?)
      if (block =~ /Mode:\s*(Managed|Ad\-hoc|Auto|Master)/i)
        network.mode = $1;
      end
      if (block =~ /Frequency:.+\(Channel (\d+)\)/i)
        network.channel = $1
      end
      if (block =~ /Quality=(\d+)\s/i)
        network.quality = $1;
      end
      if (block =~ /Signal level=([\-0-9.]*)/i)
        network.signal = $1;
      end
      if (block =~ /Noise level=([\-0-9.]*)/i)
        network.noise = $1;
      end
      if (block =~ /Encryption key:\s*(on|off)/i)
        network.encryption = $1
      end
      networks << network
    end
  
    # Sort the network list by signal strength
    return networks.sort {|x,y| x.signal <=> y.signal }
  end

end

