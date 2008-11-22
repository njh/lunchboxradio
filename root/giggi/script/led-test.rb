#!/usr/bin/ruby

require 'glk'

glk = Device::MatrixOrbital::GLK.new('/dev/ttyUSB0')
#glk.clear_screen
#glk.set_font(0)
#glk.print "Hello World!"
glk.gpo_off(1)
glk.gpo_off(2)
glk.gpo_off(3)
glk.gpo_off(4)
glk.gpo_off(5)
glk.gpo_off(6)

sleep 2

glk.gpo_on(1)
sleep 1
glk.gpo_on(2)
sleep 1
glk.gpo_on(3)
sleep 1
glk.gpo_on(4)
sleep 1
glk.gpo_on(5)
sleep 1
glk.gpo_on(6)

