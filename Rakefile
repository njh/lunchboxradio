#!/usr/bin/ruby

ROOT_DIR=File.expand_path(File.dirname(__FILE__))
require 'rake'
require 'yaml'

# Load our own task library
Dir.glob("#{ROOT_DIR}/lib/tasks/*.rake").sort.each do |filename|
  load filename
end

# Load source package rules
load "#{ROOT_DIR}/src/Rakefile"

