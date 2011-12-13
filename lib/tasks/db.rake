task :db do
  puts 'Migrating CouchDB Views'
  Rake::Task['couch_record:push'].invoke
  Rake::Task['db:migrate'].invoke
end
