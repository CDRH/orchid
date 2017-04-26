require "colorize"

class SetupGenerator < Rails::Generators::Base

  desc <<-EOS
    This generator prepares applications for API integration:
      1. Generates config/config.yml file
      2. Generates .gitignore file
      3. Includes api_bridge gem in app's Gemfile
      4. Generates facets file for customization
      5. Sets up default stylesheet variables file
  EOS

  def setup_files
    @this_app = "#{File.expand_path File.dirname(__FILE__)}/../.."
    @new_app = Rails.root

    msgs = []

    msgs << copy_initializer
    msgs << copy_configs
    msgs << facets
    msgs << footer_logo
    msgs << gems
    msgs << gitignore
    msgs << remove_files
    msgs << scripts
    msgs << stylesheet

    Bundler.with_clean_env do
      run "bundle install"
    end

    puts msgs.compact.join("\n\n")

  end

  private

  def config_replace(original, new)
    gsub_file "#{@new_app}/config/config.yml", original, new
  end

  def config_set(var_name, value)
    gsub_file "#{@new_app}/config/config.yml", /^(\s*#{var_name}:).+$/, "\\1 #{value}"
  end

  def copy_configs
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.yml", "#{@new_app}/config/config.example.yml")
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.yml", "#{@new_app}/config/config.yml")

    puts "Please enter the following for initial app customization"

    answer = prompt_for_value("Project Name (Header <h1>)", "Sample Template")
    config_set("project_name", answer)

    answer = prompt_for_value("Project Short Name (<title>, meta application-name>)", "Template")
    config_set("project_shortname", answer)

    answer = prompt_for_value("Project Subtitle (Header <h2>)", "Template Subtitle")
    config_set("project_subtitle", answer)

    answer = prompt_for_value("Dev API Path", "https://cdrhdev1.unl.edu/api")
    config_replace("api_path: https://cdrhdev1.unl.edu/api", "api_path: #{answer}")

    answer = prompt_for_value("Production API Path", "https://cdrhapi.unl.edu")
    config_replace("api_path: https://cdrhapi.unl.edu", "api_path: #{answer}")

    return "Customize your app in config/config.yml".green
  end

  def copy_initializer
    # NOTE: This could be done with the "initializer" method instead
    # http://guides.rubyonrails.org/generators.html#initializer
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.rb", "#{@new_app}/config/initializers/config.rb")
  end

  def facets
    FileUtils.cp("#{@this_app}/app/models/facets.rb", "#{@new_app}/app/models/facets.rb")
    return "Customize your facets in app/models/facets.rb".green
  end

  def footer_logo
    logo_image = "footer_unl_logo.png"
    FileUtils.cp("#{@this_app}/app/assets/images/#{logo_image}", "#{@new_app}/app/assets/images/#{logo_image}")

    return "Footer logo copied to app/assets/images/#{logo_image}"
  end

  def gems
    gem 'bootstrap-sass', '~> 3.3.6'
    gem 'jquery-rails'

    # remove the previous api_bridge gem from Gemfile
    gsub_file "#{@new_app}/Gemfile", /^(?!#\s)gem\s["']api_bridge["'].*$/, ""
    # install the correct version of the gem
    gem "api_bridge", git: "https://github.com/CDRH/api_bridge", tag: Orchid.api_bridge_version
  end

  def gitignore
    FileUtils.cp("#{@this_app}/lib/generators/templates/.gitignore", "#{@new_app}/.gitignore")
    return "Add more files to .gitignore which should not be version controlled".green
  end

  def prompt_for_value(message, default)
    puts "\n#{message}\n[#{default}]: "
    value = gets.chomp

    return value.empty? ? default : value
  end

  def remove_files
    FileUtils.rm("#{@new_app}/app/controllers/application_controller.rb")
    FileUtils.rm("#{@new_app}/app/views/layouts/application.html.erb")

    return "Application controller and layout removed to use Orchid's"
  end

  def scripts
    # Remove default JS assets so Orchid's JS pipeline is used
    FileUtils.rm_rf("#{@new_app}/app/assets/javascripts/.", secure: true

    # Create directory for auto-included app-wide JavaScript
    FileUtils.mkdir("#{@new_app}/app/assets/javascripts/global")

    return <<-EOS.green
Add app-wide JavaScript to app/assets/javascripts/global/
All .js file contents there are served with every page

May also override Orchid JS pipeline and/or any individual scripts

View-specific JS files to be added via @ext_js instance variable, e.g.:
  @ext_js = %w(leaflet search)
Small inline scripting to be added via @inline_js instance variable, e.g.:
  @inline_js = ["var power_level = 9000;"]
    EOS
  end

  def stylesheet
    # Bootstrap variable overrides
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss", "#{@new_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss")

    # Must use application.scss for mixins and variables
    FileUtils.rm("#{@new_app}/app/assets/stylesheets/application.css")
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/application.scss", "#{@new_app}/app/assets/stylesheets/application.scss")

    return <<-EOS.green
Customize Bootstrap in app/assets/stylseheets/cdrh-bootstrap-variables.scss
Application-wide styling to be added via application.scss

View-specific styling to be added to @ext_css instance variable, e.g.:
  @ext_css = %w(leaflet stamen)
Small inline styling to be added via @inline_css instance variable, e.g.:
  @inline_css = [".cats .hidden {display: none;}"]
    EOS
  end

end
