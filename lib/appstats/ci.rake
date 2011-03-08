unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks
  namespace :ci do
    desc "Perform a build on the CI server"
    task :build => ['config']  do
      begin
        Rake::Task['db:test:purge'].invoke
        Rake::Task['db:test:load'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['db:test:prepare'].invoke
        Rake::Task['spec'].invoke
        Rake::Task['metrics:all'].invoke
        Rake::Task['ci:success'].invoke
      rescue Exception => e
        Rake::Task['ci:failure'].invoke
        raise e
      end
    end

    desc "Setup the correct database configuration files"
    task :config do
      source_db_file = '/cenx/appstats/sensitive/config.yml'
      dest_db_file = "#{Rails.root}/db/config.yml"
      abort "No database file [#{source_db_file}], unable to continue CI build" unless File.exists? source_db_file
      FileUtils.cp source_db_file, dest_db_file, :preserve => false
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
