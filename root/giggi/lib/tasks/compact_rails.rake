#!/usr/bin/ruby

# Crude but effective

namespace :rails do

  desc "Delete documentation and tests from vendor/rails"
  task :compact do
  
    def rm_rails(*path)
      full_path = File.join(RAILS_ROOT, 'vendor', 'rails', *path)
      if File.exists?(full_path)
        sh 'rm', '-Rf', full_path
      end
    end
    
    rm_rails 'actionmailer'
    
    rm_rails 'actionpack/CHANGELOG'
    rm_rails 'actionpack/install.rb'
    rm_rails 'actionpack/MIT-LICENSE'
    rm_rails 'actionpack/Rakefile'
    rm_rails 'actionpack/README'
    rm_rails 'actionpack/RUNNING_UNIT_TESTS'
    rm_rails 'actionpack/test'
    
    rm_rails 'activerecord/CHANGELOG'
    rm_rails 'activerecord/README'
    rm_rails 'activerecord/RUNNING_UNIT_TESTS'
    rm_rails 'activerecord/Rakefile'
    rm_rails 'activerecord/examples'
    rm_rails 'activerecord/install.rb'
    rm_rails 'activerecord/test'
    
    rm_rails 'activeresource'
    
    rm_rails 'activesupport/CHANGELOG'
    rm_rails 'activesupport/README'
    
    rm_rails 'railties/CHANGELOG'
    rm_rails 'railties/configs'
    rm_rails 'railties/dispatches'
    rm_rails 'railties/doc'
    rm_rails 'railties/environments'
    rm_rails 'railties/fresh_rakefile'
    rm_rails 'railties/helpers'
    rm_rails 'railties/html'
    rm_rails 'railties/MIT-LICENSE'
    rm_rails 'railties/Rakefile'
    rm_rails 'railties/README'
  
  end

end