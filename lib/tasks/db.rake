namespace :db do
  # Override the original Rake task to migrate couchdb too
  task :migrate do
    puts "Migrating CouchDB Views"
    Rake::Task['couch_record:push'].invoke
  end

end