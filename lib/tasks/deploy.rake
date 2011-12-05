require 'aws/s3'

task :deploy do
  Rake::Task['deploy:update_deleted_views_file'].invoke
  Rake::Task['deploy:heroku'].invoke
  Rake::Task['deploy:migrate'].invoke
end

namespace :deploy do

  task :update_deleted_views_file => :environment do
    puts color YELLOW, 'Updating deleted views file'

    run 'git fetch heroku master:heroku'
    heroku_views = `git ls-tree -r --name-only heroku:db/couch`.split "\n"
    local_views = `git ls-tree -r --name-only master:db/couch`.split "\n"

    # views deleted since last deploy
    newly_deleted_views = heroku_views - local_views

    old_deleted_views = (File.readlines 'db/deleted_couch_views').each { |l| l.strip! }

    # union of old and new
    deleted_views = old_deleted_views | newly_deleted_views

    # remove any that currently exist (delete and re-add)
    deleted_views = deleted_views - local_views

    File.open 'db/deleted_couch_views', 'w' do |f|
      deleted_views.each do |view|
        f << view << "\n"
      end
    end

    run 'git add db/deleted_couch_views'
    run "git commit -m 'deleted views file' --only -- db/deleted_couch_views", false
    run 'git push origin master'
  end

  task :heroku do
    puts color YELLOW, 'Pushing to Heroku'

    run 'git push heroku master'
  end

  task :migrate do
    puts color YELLOW, 'Migrating Heroku'

    run 'heroku run rake db:migrate'
  end

end

# Colors
BLACK   = "\e[30m"
RED     = "\e[31m"
GREEN   = "\e[32m"
YELLOW  = "\e[33m"
BLUE    = "\e[34m"
MAGENTA = "\e[35m"
CYAN    = "\e[36m"
WHITE   = "\e[37m"

def color(color, text)
  "#{color}#{text}\033[0m"
end

def run(cmd, fail = true)
  puts '>> ' + cmd
  result = system cmd
  raise color RED, "failed" unless result || !fail
end