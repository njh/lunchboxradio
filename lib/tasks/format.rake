#!/usr/bin/ruby


def mkdir(dir)
  dir_path = "#{SETTINGS['cf_mount']}/#{dir}"
  unless File.exists?(dir_path)
    sh 'mkdir', dir_path
  end
end

def mknod(dev, type, major, minor)
  dev_path = "#{SETTINGS['cf_mount']}/dev/#{dev}"
  unless File.exists?(dev_path)
    sh 'mknod', dev_path, type, major.to_s, minor.to_s
  end
end


desc "Format the compact flash card"
task :format do

  # Check that we are root
  raise "This task should be run as root." if Process.uid != 0

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

    puts "* Making Device Files..."
    mkdir 'dev'
    mknod 'mem',            'c', 1, 1
    mknod 'kmem',           'c', 1, 2
    mknod 'null',           'c', 1, 3
    mknod 'port',           'c', 1, 4
    mknod 'zero',           'c', 1, 5
    mknod 'full',           'c', 1, 7
    mknod 'random',         'c', 1, 8
    mknod 'urandom',        'c', 1, 9
    
    mknod 'tty',            'c', 5, 0
    mknod 'console',        'c', 5, 1
    
    mknod 'hda',            'b', 3, 0
    mknod 'hda1',           'b', 3, 1
    mknod 'root',           'b', 3, 1
    
    mknod 'tty0',           'c', 4, 0
    mknod 'tty1',           'c', 4, 1
    mknod 'tty2',           'c', 4, 2
    
    mknod 'ttyp0',          'c', 3, 0
    mknod 'ttyp1',          'c', 3, 1
    mknod 'ttyp2',          'c', 3, 2
    
    mknod 'ptyp0',          'c', 2, 0
    mknod 'ptyp1',          'c', 2, 1
    mknod 'ptyp2',          'c', 2, 2
    
    mknod 'ttyS0',          'c', 4, 64
    mknod 'ttyS1',          'c', 4, 65
    mknod 'ttyUSB0',        'c', 188, 0
    
    mknod 'watchdog',       'c', 10, 130
    
    # ALSA devices
    mkdir "dev/snd"
    mknod 'snd/controlC0',  'c', 116, 0
    mknod 'snd/hwC0D0',     'c', 116, 4
    mknod 'snd/pcmC0D0p',   'c', 116, 16
    mknod 'snd/pcmC0D0c',   'c', 116, 24
    mknod 'snd/seq',        'c', 116, 1
    mknod 'snd/timer',      'c', 116, 33
    
    puts "* Installing GRUB settings..."
    mkdir "boot"
    mkdir "boot/grub"
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
