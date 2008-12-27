#!/usr/bin/ruby


# Delete documentation and other unused files from build root
task :remove_unwanted do
  puts "* Removing unwanted files from the build root"
  IO.popen("find #{BUILD_ROOT}") do |find|
    find.each_line do |file|
      file.chomp!
      SETTINGS['unwanted_files'].each do |regexp|
        full_regexp = regexp.sub(/^\^/, "^#{BUILD_ROOT}")
        if file =~ Regexp.new(full_regexp)
          if File.directory?(file)
            system('rm', '-R', file) if File.exists?(file)
          else
            system('rm', file) if File.exists?(file)
          end
        end
      end
    end
  end
end

desc "Copy binaries from Debian packages to build root"
task :copy_binaries do
  puts "* Copying files from installed Debian packages"
  SETTINGS['debian_packages'].each do |pkg|
		puts "* Installing #{pkg}..."
		
		IO.popen("dpkg -L #{pkg}" ) do |dpkg|
		  dpkg.each_line do |src_file|
		    src_file.chomp!
		    
		    # Ignore files in /etc
		    next if src_file =~ %r{^/etc}
		    
		    # Ignore files in the unwanted list
		    unwanted = false
        SETTINGS['unwanted_files'].each do |regexp|
          unwanted = true if src_file =~ Regexp.new(regexp)
		    end
		    next if unwanted
		    
		    # Copy file or create directory
		    target_file = File.join(BUILD_ROOT,src_file)
		    if File.directory?(src_file)
		      Dir.mkdir(target_file) unless File.exists?(target_file)
		    else
		      if !File.exists?(target_file) or File.mtime(src_file) > File.mtime(target_file)
		        sh 'cp', '-dp', src_file, target_file
		      end
		    end
		  end
		end
  end
end

desc "Build and Copy files into 'root' directory"
task :build => ['src:build', :copy_binaries, :remove_unwanted]
