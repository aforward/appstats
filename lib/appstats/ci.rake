unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks
  namespace :ci do
    desc "Perform a build on the CI server"
    task :build => ['config', 'create_logs']  do
      begin
        Rake::Task['ci:db_setup'].invoke
        # Rake::Task['db:test:prepare'].invoke
        Rake::Task['ci:qa'].invoke
        Rake::Task['ci:success'].invoke
      rescue Exception => e
        Rake::Task['ci:failure'].invoke
        raise e
      end
    end

    task :qa do
      Rake::Task['spec'].invoke
      Rake::Task['metrics:all'].invoke
    end

    # Creates a second database for testing the multi db access
    task :db_setup => ['config','create_logs'] do
      Rake::Task['appstats:install:migrations'].invoke
      Rake::Task['db:migrate'].invoke
    end

    desc "Setup the correct database configuration files"
    task :config do
      source_db_file = '/cenx/appstats/sensitive/config.yml'
      dest_db_file = "#{Dir.pwd}/db/config.yml"
      abort "No database file [#{source_db_file}], unable to continue CI build" unless File.exists? source_db_file
      FileUtils.cp source_db_file, dest_db_file, :preserve => false
    end

    desc "Create log files that are used when running tests"
    task :create_logs do
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

    desc "Testing the environment"
    task :test do
      system('ruby -r rubygems -e "p Gem.path"')
    end

    desc "The Build Succeeded, so tell our monitoring service"
    task :success do
      FileUtils.cp '/home/deployer/monitor/statuses/Appstats.cc.success', '/home/deployer/monitor/log/Appstats.cc', :preserve => false
    end

    desc "The Build failed, so tell our monitoring service"
    task :failure do
      FileUtils.cp '/home/deployer/monitor/statuses/Appstats.cc.failure', '/home/deployer/monitor/log/Appstats.cc', :preserve => false
    end

  end
end
