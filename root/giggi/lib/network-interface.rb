#!/usr/bin/ruby

DHCPC_PID = '/var/udhcpc.pid'
DHCPC_SCRIPT = '/etc/udhcpc.script'


class NetworkInterface
  attr_reader :name
	

  #def initialize
  #  # implemented by subclasses
  #end
  
  def bring_up
    # Bring the wireless interface up
    puts "  Bringing up #{@name}"
    system('ifconfig', @name, 'up') or 
    raise("Failed to bring up network interface: "+@name);
  end

  def bring_down
    # Bring the wireless interface down
    puts "  Bringing down #{@name}"
    system('ifconfig', @name, 'down') or 
    raise("Failed to bring down network interface: "+@name);
  end
  
  def ip_address
    ipaddr = `ip addr show dev #{@name}`
    ipaddr =~ /\s+inet (\d+\.\d+\.\d+\.\d+)\/(\d+)\s+/
    return $1
  end
  
  def set_ip_address(ip, mask, bcast)
    system('ip', 'addr', 'add',
        'dev', self.name,
        'local', "#{ip}/#{mask}",
        'broadcast', bcast
    ) or raise "Failed to configure static IP address"
  end
  
  def set_default_route(gateway)
    system('ip', 'route', 'add', 'to', '0/0', 'via', gateway, 'dev', self.name) or
    raise "Failed to add default route"
  end

  def dhcpc(ip=nil)
    if File.exists?(DHCPC_PID)
      pid = IO.readlines(DHCPC_PID).first
      $stderr.puts "Killing off old udhcpc pid #{pid}"
      Process.kill("INT", pid.to_i)
    end
  
    ## FIXME: move DHCP attempts to ruby and be more interactive
  
    # Build the command to execute
    cmd = [ 'udhcpc',
      '-n',
      '-i', @name,
      '-c', 'lunchbox',
      '-s', DHCPC_SCRIPT,
      '-p', DHCPC_PID,
      '-t', '5'
    ]
    
    # Add the IP to command if one is specified
    unless ip.nil? 
      cmd << '-r'
      cmd << ip.to_s
    end

    return system(*cmd)
  end
end

