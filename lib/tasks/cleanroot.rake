#!/usr/bin/ruby

desc "Delete any files from root, that aren't in subversion"
task :cleanroot do
  IO.popen("svn --non-interactive --ignore-externals status '#{ROOT_DIR}/root'") do |svn|
    svn.each_line do |line|
      line.chomp!
      matches = line.match(/^(.{1})(.{1})(.{1})(.{1})(.{1})(.{1}) (\/.+)$/)
      (mod, modprop, dirlock, hist, switch, repolock, file) = matches.captures
      if mod == '?'
        if File.file?(file)
          sh 'rm', file
        elsif File.symlink?(file)
				  sh 'rm', file
        elsif File.directory?(file)
				  sh 'rm', '-Rf', file
				else
				  $stderr.puts "Unable to delete unknown: #{file}"
				end
      else
        puts "Not deleting [#{mod}]: #{file}"
      end
    end
  end
end
