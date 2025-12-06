# Orchid Config
require "byebug"

PUBLIC = YAML.load_file("#{Rails.root}/config/public.yml", aliases: true)[Rails.env]
PRIVATE = YAML.load_file("#{Rails.root}/config/private.yml", aliases: true)[Rails.env]

VERSION = PUBLIC["app_options"]["version"]

API_OPTS = PUBLIC["api_options"]
API_PATH = PRIVATE["api_path"]
APP_OPTS = PUBLIC["app_options"]
IIIF_PATH = PRIVATE["iiif_path"]
STATIC_IMAGE_PATH = PRIVATE["static_image_path"]
AUDIO_FILE_PATH = PRIVATE["audio_file_path"]
VIDEO_FILE_PATH = PRIVATE["video_file_path"]

FACETS = PUBLIC["facets"]

def get_facets(facet_set)
  # facets will be sent to api in query url under f[]=
  # the api expects an array of facets
  facets = []
  facet_set.each do |facet|
    if facet.class == Array
      # a subarray will be constructed for nested bucket aggregations
      # example ["rdf.predicate[rdf.type#case_role]", "case_roles"]
      # first facet can be parsed by api to match nested fields, but is illegal in ES query
      # second facet provides an aggregation label that is legal for ES
      if facet[1]["aggregation_name"]
        facets << [facet[0], facet[1]["aggregation_name"]]
      else
        facets << facet[0]
      end
    end
  end
  facets
end

if API_PATH
  puts "Connecting to API at #{API_PATH}"
  $api = ApiBridge::Query.new(API_PATH, get_facets(Orchid::facets), API_OPTS)
else
  raise "API path not found. Check config/private.yml is correctly defined"
end

if APP_OPTS.key?("sections")
  SECTIONS = {}
  $api_sections = {}

  APP_OPTS["sections"].each do |name|
    config_path = Rails.root.join("config", "sections", "#{name}.yml")

    if File.exists?(config_path)
      SECTIONS[name] = YAML.load_file(config_path, aliases: true)[Rails.env]
      SECTIONS[name]["name"] = name
    else
      raise "Section config file not found: #{config_path}"
    end

    puts "Connecting to API for section: #{name}"
    $api_sections[name] = ApiBridge::Query.new(API_PATH,
      get_facets(Orchid::facets(section: name)), SECTIONS[name]["api_options"])
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
