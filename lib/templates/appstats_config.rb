
# LOGGER CONFIGURATIONS (i.e. what is integrated within all of your apps)
Appstats::Logger.filename_template = File.join(File.dirname(__FILE__), '..', '..', 'log','appstats') # usually left as-is
Appstats::Logger.default_contexts[:app_name] = "YOUR_APP_NAME_HERE" # replace me with your app name
