#!/usr/bin/ruby

require 'rake'
require 'rake/tasklib'
require 'digest/md5'
require 'uri'

class SourcePackageTask < Rake::TaskLib

  # Name of the source package
  attr_accessor :name

  # URL of the source code archive
  attr_accessor :archive_url

  # MD5 sum of the source code archive
  attr_accessor :archive_md5
  

  def initialize(name)
    @name = name
    @archive_url = nil
    @archive_md5 = nil

    namespace @name do
      yield self if block_given?
      define
    end

    # Add the package to the parent tasks prerequisites  
    task :clean => ["#{@name}:clean"]
    task :build => ["#{@name}:build"]
  end
  
  def archive_path
    return nil if archive_url.nil?
    url = URI.parse(archive_url)
    File.join(ROOT_DIR,'src',File.basename(url.path))
  end
  
  def build_dir
    File.join(ROOT_DIR,'src',name.to_s)
  end
  
  def calc_archive_md5
    Digest::MD5.hexdigest(File.read(archive_path))
  end
  
  def make(*args)
    sh *(['make', '-C', build_dir] + args)
  end
    
  # Create the tasks defined by this task lib.
  def define
    desc "Download source archive for #{name}"
    task :download do
      if File.exists?(archive_path)
        File::delete(archive_path) if archive_md5 != calc_archive_md5
      end
      unless File.exists?(archive_path)
        sh 'wget', '-O', archive_path, archive_url
        raise "Error: MD5 of downloaded file doesn't match" if archive_md5 != calc_archive_md5
      end
    end

    desc "Extract source tarball files for #{name}"
    task :extract => [:download] do
      # Does the build directory already exist and have something in it?
      if File.exists?(build_dir) and Dir.entries(build_dir).size > 2
        puts "Directory exists, assuming that archive is already extacted."
      else
        unless File.exists?(build_dir)
          Dir.mkdir(build_dir) or raise "Failed to create directory: #{build_dir}"
        end
        
        if archive_path =~ /\.bz2$/
          sh 'tar', '-jx', '--strip', '1', '-f', archive_path, '-C', build_dir
        elsif archive_path =~ /(\.gz|\.tgz)$/
          sh 'tar', '-zx', '--strip', '1', '-f', archive_path, '-C', build_dir
        else
          raise "Don't know how to extract archive: #{archive_path}"
        end
        
        # Run the patch task, if it exists
        patch_task = "src:#{name}:patch"
        if Rake::Task.task_defined?(patch_task)
          Rake::Task[patch_task].invoke
        end
      end
    end

    desc "Configure the #{name} package, ready for building"
    task :config => [:extract]

    desc "Build the #{name} package"
    task :build => [:config]

    desc "Clean #{name} build directory"
    task :clean do
      sh 'rm', '-R', build_dir if File.exists?(build_dir)
    end
      
    self
  end

end
