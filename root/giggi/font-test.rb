#!/usr/bin/ruby

require 'glk'


glk = Device::MatrixOrbital::GLK.new('/dev/ttyUSB0')
glk.clear_screen
glk.set_font(0)
glk.print "Hello World!"

# 0 - big, clear
# 1 - bad
# 2 - small, clear (7x40)
# 3 - bad
# 4 - bigger, compressed 
# 5 - empty