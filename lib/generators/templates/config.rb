# config/initializers/config.rb

PUBLIC = YAML.load_file("#{Rails.root}/config/public.yml")[Rails.env]
PRIVATE = YAML.load_file("#{Rails.root}/config/private.yml")[Rails.env]

VERSION = PUBLIC["app_options"]["version"]

API_OPTS = PUBLIC["api_options"]
API_PATH = PRIVATE["api_path"]
APP_OPTS = PUBLIC["app_options"]
IIIF_PATH = PRIVATE["iiif_path"]

DATE_FIRST = PUBLIC["date_range"]["first"] || ["1800", "01", "01"]
DATE_LAST = PUBLIC["date_range"]["last"] || ["1900", "12", "31"]

def date_display(date_arr)
  DateTime.new(
    date_arr[0].to_i,
    date_arr[1].to_i,
    date_arr[2].to_i
  ).strftime("%b %d, %Y")
end

DATE_DISPLAY_FIRST = date_display(DATE_FIRST)
DATE_DISPLAY_LAST = date_display(DATE_LAST)
