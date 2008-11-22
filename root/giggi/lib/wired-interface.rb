#!/usr/bin/ruby

require 'network-interface'


class WiredInterface < NetworkInterface

  INTERFACES = ['eth0','eth1']

  # Method to find an ethernet port with a link
  def WiredInterface.find_inferface_with_link
    for iface in INTERFACES
      IO.popen("ethtool #{iface}") do |io|
        while line = io.gets
          if (line =~ /Link detected: yes/)
            return self.new(iface)
          end
        end
      end
    end
    return nil
  end

  def initialize(iface)
    @name = iface
  end
end

