require 'ostruct'
require 'yaml'

config_file = YAML.load_file("#{PopsRedmineEngine::Engine.root}/config/app.yml")
app_config  = config_file['common'] || {}
app_config.update(config_file[Rails.env] || {})

ApplicationConfig = OpenStruct.new(app_config)
