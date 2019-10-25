# Orchid Config

PUBLIC = YAML.load_file("#{Rails.root}/config/public.yml")[Rails.env]
PRIVATE = YAML.load_file("#{Rails.root}/config/private.yml")[Rails.env]

VERSION = PUBLIC["app_options"]["version"]

API_OPTS = PUBLIC["api_options"]
API_PATH = PRIVATE["api_path"]
APP_OPTS = PUBLIC["app_options"]
IIIF_PATH = PRIVATE["iiif_path"]

FACETS = PUBLIC["facets"]

if API_PATH
  puts "Connecting to API at #{API_PATH}"
  $api = ApiBridge::Query.new(API_PATH, Orchid::facets.keys, API_OPTS)
else
  raise "API path not found. Check config/private.yml is correctly defined"
end

if APP_OPTS.key?("sections")
  SECTIONS = {}
  $api_sections = {}

  APP_OPTS["sections"].each do |name|
    config_path = Rails.root.join("config", "sections", "#{name}.yml")

    if File.exists?(config_path)
      SECTIONS[name] = YAML.load_file(config_path)[Rails.env]
      SECTIONS[name]["name"] = name
    else
      raise "Section config file not found: #{config_path}"
    end

    puts "Connecting to API for section: #{name}"
    $api_sections[name] = ApiBridge::Query.new(API_PATH,
      Orchid::facets(section: name).keys, SECTIONS[name]["api_options"])
  end
end

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


# App Config
