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

desc "Build and Copy files into 'root' directory"
task :build => ['src:build', :remove_unwanted]
