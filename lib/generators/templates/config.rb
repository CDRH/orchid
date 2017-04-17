# config/initializers/config.rb

CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

VERSION = CONFIG["version"]

API_PATH = CONFIG["api_path"]
API_OPTS = CONFIG["api_opts"]
