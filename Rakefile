#!/usr/bin/ruby

require 'rake'
require 'yaml'

# Some useful constants
ROOT_DIR=File.expand_path(File.dirname(__FILE__))
BUILD_ROOT=File.join(ROOT_DIR,'root')

# Load settings from YAML file
SETTINGS = YAML::load(File.read("#{ROOT_DIR}/build_settings.yml"))

# Load our own task library
Dir.glob("#{ROOT_DIR}/lib/tasks/*.rake").sort.each do |filename|
  load filename
end

# Load source package rules
load "#{ROOT_DIR}/src/Rakefile"
