#!/usr/bin/ruby
#
# Ruby module for controling the Matrix Orbital graphic LCD displays
#
# By Nicholas J Humfrey
#

module Device
module MatrixOrbital

class GLK < File
	attr_reader :lcd_type, :lcd_dimensions
	
	def initialize(port='/dev/ttyS0', baud=19200, lcd_type=nil)
	
	  # Does the device exist?
	  unless File.exists? port
	    raise "Serial port '#{port}' does not exist."
	  end
	
		# Use the lcd_type given, or ask the module
		unless lcd_type.nil?
			@lcd_type = lcd_type
		else
			@lcd_type = get_lcd_type
		end

		# Configure the serial port
		system("stty -F #{port} raw speed #{baud} cs8 -ixon -echo cbreak -isig -parenb > /dev/null")

		# Now, open the serial port
		super(port, "rb+")

		self.sync = true
	end
		
	
	
	def set_i2c_slave_address(address)
		send_command( 0x46, address )
	end
	
	
	def set_lcd_baudrate(baudrate)
		case baudrate
			when 9600 then
				send_command( 0x39, 0xCF )
			when 14400 then
				send_command( 0x39, 0x8A )
			when 19200 then
				send_command( 0x39, 0x67 )
			when 28800 then
				send_command( 0x39, 0x44 )
			when 38400 then
				send_command( 0x39, 0x33 )
			when 57600 then
				send_command( 0x39, 0x22 )
			when 76800 then
				send_command( 0x39, 0x19 )
			when 115200 then
				send_command( 0x39, 0x10 )
		else
			raise "Invalid/unsupported baud rate: #{baudrate}"
		end
	end

	## ** Flow control is unsupported **	
	#def set_flow_control_on
	#	send_command( 0x3A )
	#}
	
	def set_flow_control_off
		send_command( 0x3B )
	end
	
	
	def set_backlight_on(min=0)
		send_command( 0x42, min )
	end
	
	def set_backlight_off
		send_command( 0x46 )
	end
	
	def cursor_home
		send_command( 0x48 )
	end

	def set_cursor_position(col,row)
		send_command( 0x47, col, row )
	end

	def set_cursor_coordinate(x,y)
		send_command( 0x79, x, y )
	end
	
	def set_contrast(contrast)
		send_command( 0x50, contrast )
	end
	
	def set_and_save_contrast(contrast)
		send_command( 0x91, contrast )
	end
	
	def set_brightness(brightness)
		send_command( 0x99, brightness )
	end
	
	def set_and_save_brightness(brightness)
		send_command( 0x98, brightness )
	end
	
	def set_autoscroll_on
		send_command( 0x51 )
	end
	
	def set_autoscroll_off
		send_command( 0x52 )
	end
	
	
	def set_drawing_color(color)
		send_command( 0x63, color )
	end
	
	def clear_screen
		send_command( 0x58 )
	end
	
	def draw_bitmap(refid, x, y)
		send_command( 0x62, refid, x, y )
	end
	
	def draw_pixel(x, y)
		send_command( 0x70, x, y )
	end
	
	def draw_line(x1, y1, x2, y2)
		send_command( 0x6C, x1, y1, x2, y2 )
	end
	
	def draw_line_continue(x, y)
		send_command( 0x65, x, y )
	end
	
	def draw_rect(color, x1, y1, x2, y2)
		send_command( 0x72, color, x1, y1, x2, y2 )
	end
	
	
	def delete_bitmap(refid)
		send_command( 0xAD, 0x01, refid )
	end
	
	def delete_font(refid)
		send_command( 0xAD, 0x00, refid )
	end

	def set_font(refid)
		send_command( 0x31, refid )
	end
	
	
	def wipe_filesystem
		send_command( 0x21, 0x59, 0x21 )
	end
	
	def get_filesystem_space
		send_command( 0xAF )
	
		#my count = getint()
		
		#count |= ( & 0xFF) << 0;
		#count |= (getchar() & 0xFF) << 8;
		#count |= (getchar() & 0xFF) << 16;
		#count |= (getchar() & 0xFF) << 24;
		#
		#return count;
	end
	
	def get_filesystem_directory
		send_command( 0xB3 )
	
		#my lsb = getchar()
		
		#my @bytes = getbytes( 4 )
	
		#my count = 0;
		#count |= (@bytes[0] & 0xFF) << 0;
		#count |= (@bytes[1] & 0xFF) << 8;
		#count |= (@bytes[2] & 0xFF) << 16;
		#count |= (@bytes[3] & 0xFF) << 24;
		
		#return count;
		
		#return lsb;
	end
	
	def draw_solid_rect(color, x1, y1, x2, y2)
		send_command( 0x78, color, x1, y1, x2, y2 )
	end

	def gpo_off(num)
	   send_command( 0x56, num )
	end

	def gpo_on(num)
	  send_command( 0x57, num )
	end

	def set_led(led,state)
	  if (led == 0)
	    gpo_base = 1
	  elsif (led == 1)
	    gpo_base = 3
	  elsif (led == 2)
	    gpo_base = 5
	  else
	    raise 'Invalid LED number'
	  end
	  
	  if (state == 'off' or state === false)
	    gpo_on( gpo_base )
	    gpo_on( gpo_base+1 )
	  elsif (state == 'red' or state === true)
	    gpo_off( gpo_base )
	    gpo_on( gpo_base+1 )
	  elsif state == 'green'
	    gpo_on( gpo_base )
	    gpo_off( gpo_base+1 )
	  elsif state == 'yellow'
	    gpo_off( gpo_base )
	    gpo_off( gpo_base+1 )
	  end
	end

	
	def get_firmware_version
		# FIXME: make this work
		#unless (defined self->{'firmware_version'end) {
		#	send_command( 0x36 )
		#
		#	my value = sprintf("%2.2x", self->getchar() )
		#	my (major, minor) = (value =~ /(\w{1end)(\w{1end)/)
		#	self->{'firmware_version'end = "major.minor";
		#end
		
		#return self->{'firmware_version'end;
	end


	## Send a command to the display
	def send_command(command, *args)
		args.unshift(0xFE, command)
		self.print( args.pack('C*') )
	end
	
	## Send message to display and STDOUT too
	def puts_console(*args)
	  $stdout.puts(*args)
	  self.puts(*args)
	end
	
private

	
	def get_lcd_type
		# FIXME: do this properly using 0x37 command
		return 'GLK24064-25';
	end

	def get_lcd_dimensions
		return [240,64]
	end

end # GLK
end # MatrixOrbital
end # Device
