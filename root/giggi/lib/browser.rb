#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'


class Browser
  attr_accessor :location
  attr_reader :referer
  
  def initialize(url_str)
    @location = URI.parse(url_str)
    @referer = nil
  end
  
  def create_new_location(url, newloc)
    if newloc =~ %r{^\w+:}
      URI.parse(newloc)
    else
      url.merge(newloc)
    end
  end
  
  def show_dialog(yaml)
    # implement in sub-class
  end
  
  

  def run
  
    loop do
    
      begin
        if @location.nil? or @location.scheme.nil?
          raise "Error: current location is nil"
        elsif @location.scheme == 'http'
          res = Net::HTTP.start(@location.host, @location.port) {|http| http.get(@location.path)}
          if res.code == '200'
            data = YAML::load(res.body)
            newloc = show_dialog(data)
            @referer = @location
            @location = create_new_location(@location, newloc)
          elsif res.code =~ /^30?$/
            # FIXME: deal with redirects
          else
            raise "HTTP get failed: #{res.message}"
          end
        elsif @location.scheme == 'ruby'
          # FIXME: only allow ruby commands from localhost
          puts "Evaluating '#{@location.opaque}'"
          Kernel.send(@location.opaque)
        else
          raise "Unable to handle URL scheme: #{@location}"
        end
      
      # FIXME: catch more exceptions
      rescue SystemExit,SignalException => exp
        raise exp
      rescue Exception => exp
        # FIXME: give user a chance to abort
        show_dialog('type' => 'msgbox', 'title' => 'Error', 'text' => exp.message)
        @location = @referer
      end
    
    end
    
  end
  

end


