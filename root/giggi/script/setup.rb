#!/usr/bin/ruby
#

$:.unshift File.dirname( File.expand_path(__FILE__) )

require 'wired-interface'
require 'wireless-interface'
require 'audio-mixer'
require 'yaml'
require 'glk'

SERIAL_PORT='/dev/ttyUSB0'
NETWORKS_DIR='/giggi/networks'
TIME_SERVER='time.giggi.org'

LCD_MODULES = [
  ['ohci-hcd'],
  ['ftdi_sio', 'vendor=0x1b3d', 'product=0x0127'],
  ['pl2303']
]

AUDIO_MODULES = [
  ['ohci-hcd'],
  ['snd-pcm'],
  ['snd-usb-audio']
]

WIRED_MODULES = [
  ['via-rhine']
]

WIRELESS_MODULES = [
  ['wlan'],
  ['wlan_wep'],
  ['wlan_scan_sta'],
  ['ath_rate_sample'],
  ['ath_pci', 'countrycode=826', 'autocreate=sta']
]



def load_modules(module_list)
  for mod in module_list
    system('modprobe', *mod) or 
    raise "Failed to load module: "+mod.first
  end
end



# Open connection to the LCD screen
load_modules( LCD_MODULES )
$glk = Device::MatrixOrbital::GLK.new(SERIAL_PORT)
$glk.set_font(1)
$glk.clear_screen
$glk.set_contrast(128)
$glk.set_brightness(64)
$glk.set_backlight_on
$glk.set_autoscroll_on
$glk.puts_console "Welcome!"

$glk.set_led(0, false)
$glk.set_led(1, false)
$glk.set_led(2, false)


## Wrap the rest of the script up in an exection handler
begin


  # Setup audio
  load_modules( AUDIO_MODULES )
  mixer = AudioMixer.new
  system('aplay', '/giggi/lib/bbcb_beep.wav')
  
  
  # Try wired first
  $glk.puts_console "Checking wired interfaces."
  load_modules( WIRED_MODULES )
  iface = WiredInterface.find_inferface_with_link
  unless iface.nil?
    $glk.puts_console "Found wired interface with link: #{iface.name}"

    # Bring interface up
    iface.bring_up
    config = YAML.load_file( "#{NETWORKS_DIR}/ethernet.yml" )
  else
    $glk.puts_console "No wired interfaces with link found."

    # Load wireless modules
    load_modules( WIRELESS_MODULES )
    iface = WirelessInterface.new
    
    # Switch to automatic and bring interface up
    iface.standard = 'auto'
    iface.bring_up

    ## Repeatedly search for a wireless network
    i = 0
    while i<10
      $glk.puts_console "Performing wireless network scan on #{iface.name}..."
      networks = iface.scan_networks
      for network in networks
        $glk.puts_console "  network: #{network.essid} (#{network.signal} dB)"
        filename = "#{NETWORKS_DIR}/#{network.essid}.yml"
        if File.exists? filename
          config = YAML.load_file( filename )
          break
        end
      end
      break unless config.nil?
      sleep 2
      i+=1
    end

    ## Got a wireless network ?
    if config.nil?
      raise "Failed to find a wireless network"
    end

    # Join the wireless network we found
    $glk.puts_console "Joining network: #{config['wireless-essid']}"
    iface.standard = config['wireless-standard']
    iface.mode = config['wireless-mode']
    iface.essid = config['wireless-essid']
    iface.wep_key = config['wireless-key']
  end
  
  
  


  # Throw away old configuration    
  system('ip', 'addr', 'flush', 'dev', iface.name) or
  raise "Failed to flish old interface address"
  system('ip', 'route', 'flush', 'default') or
  raise "Failed to flush routing table"

  # Use DHCP?
  if (config['ip-method'] == 'static') then
    $glk.puts_console "Setting static IP address..."
    
    # Assign new address
    iface.set_ip_address(
      config['ip-address'],
      config['ip-netmask'],
      config['ip-broadcast']
    )
    
    # Add route to default gateway
    iface.set_default_route( config['ip-gateway'] )
    
    # Configure DNS
    File.open('/etc/resolv.conf', "w") { |resolv|
      resolv.puts "search #{config['ip-domain']}"
      resolv.puts "nameserver #{config['ip-nameserver']}"
    }
    
  else
    # Configure IP using DHCP
    puts "IP Method: #{config['ip-method']}"
    $glk.puts_console 'Starting DHCP client...'
    iface.dhcpc(config['ip-address'])
  end
  
  # Display our IP address
  $glk.puts_console "IP: #{iface.ip_address}"
  
  # Set the system clock
  $glk.puts_console 'Setting system clock:'
  system("rdate", TIME_SERVER)
  $glk.puts_console "  "+Time.now.strftime("%Y-%m-%d %H:%M")

rescue => exception
  # Something very bad happened
  $glk.puts_console "Fatal error: #{exception}"
  $stderr.print exception.backtrace.join("\n")
end
