
# LOGGER CONFIGURATIONS (i.e. what is integrated within all of your apps)
Appstats::Logger.filename_template = "log/appstats" # usually left as-is
Appstats::Logger.default_contexts[:app_name] = "YOUR_APP_NAME_HERE" # replace me with your app name

# LOG COLLECTOR (i.e. the process / app that  downloads all remote logs and processed them)
Appstats::LogCollector.downloaded_log_directory = "/tmp" # only required for consolidated app