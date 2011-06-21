unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks
  namespace :ci do
    desc "Perform a build on the CI server"
    task :build  do
      begin
        Rake::Task['ci:rebase'].invoke
        Rake::Task['ci:db:config'].invoke
        Rake::Task['ci:db:logs'].invoke
        Rake::Task['ci:db:reset'].invoke
        Rake::Task['ci:qa'].invoke
        Rake::Task['ci:success'].invoke
      rescue Exception => e
        Rake::Task['ci:failure'].invoke
        raise e
      end
    end
    
    desc "Update your code base (will erase local changes!!!)"
    task :rebase do
      system('git checkout .')
      system('git pull --rebase')
    end

    desc "Run QA"
    task :qa do
      Rake::Task['ci:rspec'].invoke
      # Rake::Task['metrics:all'].invoke
    end

    desc "Run Rspec"
    RSpec::Core::RakeTask.new(:rspec) do |t|
      system "mkdir -p ../public" unless File.exists?("../public")
      t.pattern = "./spec/**/*.rb"
      t.rspec_opts = ["--format", "html", "--out", "../public/rspec.html"]
      t.fail_on_error = true
    end

    desc "The Build Succeeded, so tell our monitoring service"
    task :success do
      FileUtils.cp '/home/deployer/monitor/config/statuses/Appstats.cc.success', '/home/deployer/monitor/log/Appstats.cc', :preserve => false
    end

    desc "The Build failed, so tell our monitoring service"
    task :failure do
      FileUtils.cp '/home/deployer/monitor/config/statuses/Appstats.cc.failure', '/home/deployer/monitor/log/Appstats.cc', :preserve => false
    end

    namespace :db do

      desc "Setup the correct database configuration files"
      task :config do
        source_db_file = '/cenx/appstats/sensitive/database.yml'
        dest_db_file = "#{Dir.pwd}/db/config.yml"
        abort "No database file [#{source_db_file}], unable to continue CI build" unless File.exists? source_db_file
        FileUtils.cp source_db_file, dest_db_file, :preserve => false
      end
      
      desc "Create log files that are used when running tests"
      task :logs do
        if not File.exists?('log') then
          FileUtils.mkdir 'log'
        else
          if not File.directory?('log') then
            FileUtils.rm 'log'
            FileUtils.mkdir 'log'
          end
        end
        [4, 7, 8].each do |i|
          FileUtils.touch "log/appstats_remote_log_2#{i}.log"
        end
      end

      desc "Setup the database"
      task :reset do
        Rake::Task['appstats:install:migrations'].invoke
        Rake::Task['db:migrate'].invoke
      end
    end
  end
end
