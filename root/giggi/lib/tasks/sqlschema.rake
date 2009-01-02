namespace :db do
  namespace :sqlschema do
    def sqlite_database_path
      env = Rails::configuration.environment
      config = Rails::configuration.database_configuration[env.to_s]
      dbfile = config['database'] || config['dbfile']
      File.expand_path(dbfile, RAILS_ROOT)
    end
    
    def schema_path
      "#{RAILS_ROOT}/db/schema.sql"
    end
  
    desc "Create a db/schema.sql file"
    task :dump => :environment do
      sh "sqlite3 #{sqlite_database_path} .schema > #{schema_path}"
    end

    desc "Load a schema.sql file into the database"
    task :load => :environment do
      sh "sqlite3 #{sqlite_database_path} < #{schema_path}"
    end
  end
end
