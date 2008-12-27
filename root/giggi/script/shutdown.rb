#!/usr/bin/ruby
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'glk'
SERIAL_PORT='/dev/ttyUSB0'

# Open connection to the LCD screen
$glk = Device::MatrixOrbital::GLK.new(SERIAL_PORT)
$glk.clear_screen

