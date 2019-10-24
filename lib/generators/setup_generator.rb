class SetupGenerator < Rails::Generators::Base

  desc <<-EOS
    This generator prepares applications for API integration:
      - Generates config files
      - Generates favicon and footer_logo images
      - Updates Gemfile to add dependencies, remove unwanted, replace unsupported gems
      - Generates .gitignore file
      - Generates locales en file for customization
      - Removes app's application controller and layout to use Orchid's
      - Removes app's application.js; generates new one, "global" directory,
        and app-named script
      - Generates bootstrap variable file; removes app's application.css;
        generates new Sass one, "global" directory, and app-named stylesheet
  EOS

  def setup_files
    @this_app = "#{File.expand_path File.dirname(__FILE__)}/../.."
    @new_app = Rails.root
    @new_app_name = Rails.application.class.name.split("::").first.underscore

    msgs = []
    msgs << "\n\nSetup Review\n============"
    msgs << copy_initializer
    msgs << copy_configs_and_locales
    msgs << copy_remaining_templates
    msgs << favicon
    msgs << footer_logo
    msgs << gems
    msgs << gitignore
    msgs << handle_exceptions
    msgs << helpers
    msgs << remove_files
    msgs << scripts
    msgs << stylesheet
    msgs << "For further app configuration, read more at https://github.com/CDRH/orchid#configuration"

    Bundler.with_clean_env do
      run "bundle install"
    end

    puts msgs.compact.join("\n\n")

  end

  private

  def config_replace(config_type, to_replace, replace_with)
    gsub_file "#{@new_app}/config/#{config_type}.yml", to_replace, replace_with
  end

  # config_type: path to file from config directory
  # var_name: the key in the yaml file in question
  # value: the value assigned to the key, replaces existing values
  # uncomment: if this key is commented, uncomment it
  def config_set(config_type, var_name, value, uncomment: false)
    file = "#{@new_app}/config/#{config_type}.yml"
    # expecting spaces, possible comment character (#), and key: value
    # capture groups
    #   1: entire string from beginning of the line to the key
    #   2: spaces before the key, not including a comment character
    #   3: just the key
    to_replace = /^((\s*)(?:#\s*)?(#{var_name}:)).*$/
    # either construct uncomment version of line or leave it as is
    replace_with = uncomment ? "\\2\\3 #{value}" : "\\1 #{value}"

    gsub_file file, to_replace, replace_with
  end

  def copy_configs_and_locales
    # config files
    FileUtils.cp("#{@this_app}/lib/generators/templates/private.yml", "#{@new_app}/config/private.example.yml")
    FileUtils.cp("#{@this_app}/lib/generators/templates/private.yml", "#{@new_app}/config/private.yml")
    FileUtils.cp("#{@this_app}/lib/generators/templates/public.yml", "#{@new_app}/config/public.yml")
    # en locale file is always copied by default
    FileUtils.cp("#{@this_app}/config/locales/en.yml", "#{@new_app}/config/locales/en.yml")

    puts "Please enter the following for initial app customization"

    lang_default = prompt_for_value("Primary Language", "en")
    config_set("public", "language_default", lang_default)

    langs = prompt_for_value("All Languages (separated with a pipe: en|es|cz)",
                             "en")
    config_set("public", "ALL_LANGUAGES", langs)

    langs = [] if langs.blank?
    Array(langs).each do |lang|
      # for each language which is not english, create a locale file
      next if lang == "en"
      copy_locale(lang)
    end

    # locales customization
    project_name = prompt_for_value("Project Name (Site header title)", "Sample Template")
    project_shortname = prompt_for_value("Project Short Name (<title>, <meta application-name>)", "Template")
    project_subtitle = prompt_for_value("Project Subtitle (Site header subtitle)", "Template Subtitle")

    # If the user selects a non-English language, set up a locale file.
    # At this moment, Orchid supports multiple languages but does not ship with
    # pre-made translations. Users will need to supply their own values for the
    # strings in the file.

    Array(langs).each do |lang|
      config_set("locales/#{lang}", "project_name", project_name, uncomment: true)
      config_set("locales/#{lang}", "project_shortname", project_shortname, uncomment: true)
      config_set("locales/#{lang}", "project_subtitle", project_subtitle, uncomment: true)
      # remove unnecessary comment from locale file copied from Orchid
      gsub_file "#{@new_app}/config/locales/#{lang}.yml",
        /^\s*# Below commented to avoid fallback use.+$/, ""
    end

    # public media settings
    answer = prompt_for_value("Media Server Directory", "sample_template")
    config_set("public", "media_server_dir", answer)

    answer = prompt_for_value("Thumbnail Size (default: !200,200)", "!200,200")
    config_set("public", "thumbnail_size", answer)

    # private config customization
    answer = prompt_for_value("Dev API Path", "https://cdrhdev1.unl.edu/api/v1")
    config_replace("private", "api_path: https://cdrhdev1.unl.edu/api/v1", "api_path: #{answer}")

    answer = prompt_for_value("Production API Path", "https://cdrhapi.unl.edu/v1")
    config_replace("private", "api_path: https://cdrhapi.unl.edu/v1", "api_path: #{answer}")

    answer = prompt_for_value("Dev IIIF Path", "https://cdrhdev1.unl.edu/iiif/2")
    config_replace("private", "iiif_path: https://cdrhdev1.unl.edu/iiif/2", "iiif_path: #{answer}")

    answer = prompt_for_value("Production IIIF Path", "https://cdrhmedia.unl.edu/iiif/2")
    config_replace("private", "iiif_path: https://cdrhmedia.unl.edu/iiif/2", "iiif_path: #{answer}")

    <<-HEREDOC
Configuration files copied to config/private.example.yml, config/private.yml, and config/public.yml.
Locale files copied to config/locales
Updated with initial app customizations
    HEREDOC
  end

  def copy_initializer
    # NOTE: This could be done with the "initializer" method instead
    # http://guides.rubyonrails.org/generators.html#initializer
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.rb", "#{@new_app}/config/initializers/config.rb")

    return "Initializer to load config values into app copied to config/initializers/config.rb"
  end

  def copy_locale(lang)
    FileUtils.cp("#{@this_app}/config/locales/en.yml", "#{@new_app}/config/locales/#{lang}.yml")
    gsub_file "#{@new_app}/config/locales/#{lang}.yml", /^en:$/, "#{lang}:"
  end

  def copy_remaining_templates
    FileUtils.cp("#{@this_app}/lib/generators/templates/redirects.yml", "#{@new_app}/config/redirects.example.yml")
    FileUtils.mkdir("#{@new_app}/config/sections/")
    FileUtils.cp("#{@this_app}/lib/generators/templates/section.yml", "#{@new_app}/config/sections/section.example.yml")

    <<-MSG
Redirect middleware configuration example file copied to
  config/redirects.example.yml
Section configuration example file copied to config/sections/section.example.yml
    MSG
  end

  def favicon
    FileUtils.cp("#{@this_app}/app/assets/images/favicon.png", "#{@new_app}/app/assets/images/favicon.png")

    return "Favicon copied to app/assets/images/favicon.png"
  end

  def footer_logo
    logo_image = "footer_logo.png"
    FileUtils.cp("#{@this_app}/app/assets/images/#{logo_image}", "#{@new_app}/app/assets/images/#{logo_image}")

    return "Footer logo placeholder copied to app/assets/images/#{logo_image}"
  end

  def gems
    # Replace sass-rails with sassc-rails
    gsub_file "#{@new_app}/Gemfile", /^(gem 'sass-rails'.*)$/,
      "gem 'sassc-rails', '~> 2.1'"

    # Remove turbolinks gem
    gsub_file "#{@new_app}/Gemfile", /^(gem 'turbolinks'.*)$/, "#\\1"

    # Replace chromedriver-helper with webdrivers
    gsub_file "#{@new_app}/Gemfile",
      /chromedriver to run system tests with Chrome/,
      "web drivers to run system tests with browsers"
    gsub_file "#{@new_app}/Gemfile", /^(gem 'chromedriver-helper'.*)$/,
      "gem 'webdrivers'"

    # Add Bootstrap and jQuery gems
    gem 'bootstrap-sass', '~> 3.4.1'
    gem 'jquery-rails', '~> 4.3'

    <<-MSG.chomp
Gems:
  sass-rails replaced with sassc-rails
  turbolinks removed
  chromedriver-helper replaced with webdrivers
  bootstrap-sass added
  jquery-rails added
    MSG
  end

  def gitignore
    FileUtils.cp("#{@this_app}/lib/generators/templates/.gitignore", "#{@new_app}/.gitignore")

    return "Orchid .gitignore file copied to app's root directory"
  end

  def handle_exceptions
    inject_into_file "#{@new_app}/config/application.rb", after: "config.load_defaults 5.1\n" do <<-EOS
    # Enable custom error pages
    config.exceptions_app = self.routes
    EOS
    end
    return "Added exceptions handling into application.rb"
  end

  def helpers
    FileUtils.rm("#{@new_app}/app/helpers/application_helper.rb")
    FileUtils.cp(Dir.glob("#{@this_app}/app/helpers/*_helper.rb"), "#{@new_app}/app/helpers/")

    return "Copied extendable helper files which include Orchid's to app"
  end

  def prompt_for_value(message, default)
    puts "\n#{message}\n[#{default}]: "
    value = gets.chomp

    return value.empty? ? default : value
  end

  def remove_files
    FileUtils.rm("#{@new_app}/app/controllers/application_controller.rb")
    FileUtils.rm("#{@new_app}/app/views/layouts/application.html.erb")

    return "Removed app's application controller and layout so it uses Orchid's"
  end

  def scripts
    # Remove default JavaScript assets to be replaced from Orchid
    FileUtils.rm_rf("#{@new_app}/app/assets/javascripts/.", secure: true)

    # Copy modified manifest.js for Sprockets 3.x compatibility
    # and to include Orchid's manifest in main app
    FileUtils.cp("#{@this_app}/app/assets/config/manifest.js", "#{@new_app}/app/assets/config/manifest.js")

    # Copy new application.js which includes Orchid and app-specific JavaScript
    FileUtils.cp("#{@this_app}/app/assets/javascripts/application.js", "#{@new_app}/app/assets/javascripts/application.js")

    # Create global JS dir & touch app-named file for app-wide scripting
    FileUtils.mkdir("#{@new_app}/app/assets/javascripts/global")
    FileUtils.touch("#{@new_app}/app/assets/javascripts/global/#{@new_app_name}.js")

    return "Replaced app's JavaScript assets with Orchid's.\nCreated global/ directory and file with app name for app-wide JavaScript"
  end

  def stylesheet
    # Bootstrap variable overrides
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/bootstrap-variables.scss", "#{@new_app}/app/assets/stylesheets/bootstrap-variables.scss")

    # Main app application.scss needed for relative app-specific global/* import
    FileUtils.rm("#{@new_app}/app/assets/stylesheets/application.css")
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/application.scss", "#{@new_app}/app/assets/stylesheets/application.scss")

    # Create global stylesheets dir & touch app-named file for app-wide styles
    FileUtils.mkdir("#{@new_app}/app/assets/stylesheets/global/")
    FileUtils.touch("#{@new_app}/app/assets/stylesheets/global/#{@new_app_name}.scss")

    return "Replaced app's stylesheet assets with Orchid's.\nCreated global/ directory and file with app name for app-wide styling"
  end

end
