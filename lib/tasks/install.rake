#!/usr/bin/ruby


desc "Mount the target compact flash card"
task :mount do

  # Check that we are root
  raise "This task should be run as root." if Process.uid != 0

  # Ensure that it is unmounted
  system "umount #{SETTINGS['cf_mount']} > /dev/null"
  
  # Re-read the partition table
  system "hdparm -z #{SETTINGS['cf_device']} > /dev/null"
  sleep 1
  
  # Now check the filesystem
  puts "* Checking the filesystem..."
  sh 'fsck.ext2', SETTINGS['cf_partition']
  
  puts "* Mounting Compact Flash...";
  sh 'mount', '-text2', SETTINGS['cf_partition'], SETTINGS['cf_mount']

end



desc "Copy build directory on to the compact flash card"
task :install => [:mount] do

  begin
  
    # Copy the build root on to the compact flash
    # all files and directories will be owned by root
    sh 'rsync',
       '--verbose',         # Verbose, display the changed files
       '--recursive',       # Syncronise files and folders
       '--links',           # Copy symbolic links
       '--hard-links',      # Preserve hard links
       '--perms',           # Preserve file permissions
       '--times',           # Preserve modification times
       '--exclude=.svn',    # Exclude Subversion repository files
       "#{ROOT_DIR}/root/", # Source directory
       SETTINGS['cf_mount'] # Target directory
  
  ensure
    puts "* Unmounting Compact Flash..."
    sh 'umount', SETTINGS['cf_mount']
    sh 'eject', SETTINGS['cf_partition']
  end

end
