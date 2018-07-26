class SetupGenerator < Rails::Generators::Base

  desc <<-EOS
    This generator prepares applications for API integration:
      1. Generates config files
      2. Generates facets file for customization
      3. Generates favicon and footer_logo images
      4. Disables turbolinks and adds api_bridge gem to app's Gemfile
      5. Generates .gitignore file
      6. Generates locales en file for customization
      7. Removes app's application controller and layout to use Orchid's
      8. Removes app's application.js; generates new one, "global" directory,
         and app-named script
      9. Generates bootstrap variable file; removes app's application.css;
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
    msgs << facets
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

  def config_replace(config_type, original, new)
    gsub_file "#{@new_app}/config/#{config_type}.yml", original, new
  end

  def config_set(config_type, var_name, value)
    gsub_file "#{@new_app}/config/#{config_type}.yml", /^(\s*#{var_name}:).+$/, "\\1 #{value}"
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

    langs = prompt_for_value("All Languages (separate with a pipe: en|es|de)", "en")
    config_set("public", "languages", langs)

    # if the user selects a non english language, copy the locale file there as well
    langs.split("|").each do |lang|
      next if lang == "en"
      FileUtils.cp("#{@this_app}/config/locales/en.yml", "#{@new_app}/config/locales/#{lang}.yml")
      gsub_file "#{@new_app}/config/locales/#{lang}.yml", /^en:$/, "#{lang}:"
    end

    # locales customization
    answer = prompt_for_value("Project Name (Header <h1>)", "Sample Template")
    config_set("locales/#{lang_default}", "project_name", answer)

    answer = prompt_for_value("Project Short Name (<title>, <meta application-name>)", "Template")
    config_set("locales/#{lang_default}", "project_shortname", answer)

    answer = prompt_for_value("Project Subtitle (Header <h2>)", "Template Subtitle")
    config_set("locales/#{lang_default}", "project_subtitle", answer)

    # private config customization
    answer = prompt_for_value("Dev API Path", "https://cdrhdev1.unl.edu/api/v1")
    config_replace("private", "api_path: https://cdrhdev1.unl.edu/api/v1", "api_path: #{answer}")

    answer = prompt_for_value("Production API Path", "https://cdrhapi.unl.edu/v1")
    config_replace("private", "api_path: https://cdrhapi.unl.edu/v1", "api_path: #{answer}")

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

  def facets
    FileUtils.cp("#{@this_app}/app/models/facets.rb", "#{@new_app}/app/models/facets.rb")

    return "Orchid facets copied to app/models/facets.rb"
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
    gem 'bootstrap-sass', '~> 3.3.6'
    gem 'jquery-rails', '~> 4.3'

    # Remove turbolinks gem
    gsub_file "#{@new_app}/Gemfile", /^(gem 'turbolinks'.*)$/, "#\\1"

    # Install the version of api_bridge Orchid specifies
    gem "api_bridge", git: "https://github.com/CDRH/api_bridge", tag: Orchid.api_bridge_version

    return "Gems: Turbolinks removed and api_bridge added"
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
