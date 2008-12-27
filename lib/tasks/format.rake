#!/usr/bin/ruby


def mkdir_nofail(path)
  unless File.exists?(path)
    Dir.mkdir(path)
  end
end

desc "Format the compact flash card"
task :format do

  # Check that we are root
  raise "This script should be run as root." if Process.uid != 0

  # FIXME: check that device isn't mounted

  begin
    # Little hack to make linux recheck partitions (better way?)
    puts "* Checking partitions..."
    sh "fdisk -l #{SETTINGS['cf_device']} > /dev/null"
    sleep 1
  
    puts "* Formatting #{SETTINGS['cf_partition']}..."
    sh 'mkfs.ext2', '-Lroot', SETTINGS['cf_partition']
    sh 'tune2fs', '-c0', '-i0', SETTINGS['cf_partition']
  
    puts "* Mounting Compact Flash..."
    sh 'mount', '-text2', SETTINGS['cf_partition'], SETTINGS['cf_mount']
    
    puts "* Installing GRUB settings..."
    mkdir_nofail "#{SETTINGS['cf_mount']}/boot"
    mkdir_nofail "#{SETTINGS['cf_mount']}/boot/grub"
    sh 'cp', '-f', "#{ROOT_DIR}/root/boot/grub/menu.lst", "#{SETTINGS['cf_mount']}/boot/grub/menu.lst"
    sh 'cp', '-f', "#{ROOT_DIR}/root/boot/grub/device.map", "#{SETTINGS['cf_mount']}/boot/grub/device.map"
    
    
    puts "* Installing GRUB into Master Boot Record..."
    sh 'grub-install', '--no-floppy', "--root-directory=#{SETTINGS['cf_mount']}", SETTINGS['cf_device']
  ensure
    puts "* Unmounting Compact Flash..."
    sh 'umount', SETTINGS['cf_mount']
    sh 'eject', SETTINGS['cf_partition']
  end


end
