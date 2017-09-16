require "colorize"

class SetupGenerator < Rails::Generators::Base

  desc <<-EOS
    This generator prepares applications for API integration:
      1. Generates config files and config/config.yml file
      2. Generates facets file for customization
      3. Generates favicon and footer_logo images
      4. Disables turbolinks and adds api_bridge gem to app's Gemfile
      5. Generates .gitignore file
      6. Removes app's application controller and layout to use Orchid's
      7. Removes app's application.js; generates new one, "global" directory,
         and app-named script
      8. Generates bootstrap variable file; removes app's application.css;
         generates new Sass one, "global" directory, and app-named stylesheet
  EOS

  def setup_files
    @this_app = "#{File.expand_path File.dirname(__FILE__)}/../.."
    @new_app = Rails.root
    @new_app_name = Rails.application.class.name.split("::").first.underscore

    msgs = []

    msgs << copy_initializer
    msgs << copy_configs
    msgs << facets
    msgs << favicon
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

    answer = prompt_for_value("Project Short Name (<title>, <meta application-name>)", "Template")
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

  def favicon
    FileUtils.cp("#{@this_app}/app/assets/images/favicon.png", "#{@new_app}/app/assets/images/favicon.png")
    return "Favicon copied to app/assets/images/favicon.png. Customize implementation in views/layouts/head/_favicon.html.erb".green
  end

  def footer_logo
    logo_image = "footer_logo.png"
    FileUtils.cp("#{@this_app}/app/assets/images/#{logo_image}", "#{@new_app}/app/assets/images/#{logo_image}")

    return "Footer logo copied to app/assets/images/#{logo_image}"
  end

  def gems
    gem 'bootstrap-sass', '~> 3.3.6'
    gem 'jquery-rails'

    # Remove turbolinks gem
    gsub_file "#{@new_app}/Gemfile", /^(gem 'turbolinks'.*)$/, "#\\1"

    # Remove the previous api_bridge gem from Gemfile
    gsub_file "#{@new_app}/Gemfile", /^gem 'api_bridge'.*\n$/, ""

    # Install the correct version of the gem
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

    return "Removed application controller and layout to use Orchid's"
  end

  def scripts
    # Remove default JavaScript assets to be replaced from Orchid
    FileUtils.rm_rf("#{@new_app}/app/assets/javascripts/.", secure: true)

    # Copy new application.js which includes Orchid and app-specific JavaScript
    FileUtils.rm("#{@new_app}/app/assets/javascripts/application.js")
    FileUtils.cp("#{@this_app}/app/assets/javascripts/application.js", "#{@new_app}/app/assets/javascripts/application.jss")

    # Create global JS dir & touch app-named file for app-wide scripting
    FileUtils.mkdir("#{@new_app}/app/assets/javascripts/global")
    FileUtils.touch("#{@new_app}/app/assets/javascripts/global/#{@new_app_name}.js")

    return <<-EOS.green
JavaScript
==========
One should normally not need to edit app/assets/application.js

Add app-wide JavaScript via .js files in app/assets/javascripts/global/

Conditional scripting files included via @ext_js instance variable, e.g.:
  @ext_js = %w(leaflet search)

Conditional inline scripting included via @inline_js instance variable, e.g.:
  @inline_js = ["var power_level = 9000;"]
    EOS
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

    return <<-EOS.green
Sass/CSS
========
One should normally not need to edit app/assets/application.scss

Customize Bootstrap in app/assets/stylseheets/bootstrap-variables.scss

Add app-wide styling to app/assets/stylesheets/global/#{@new_app}.scss
or other stylesheets in app/assets/stylesheets/global/

Conditional stylesheets are included via @ext_css instance variable, e.g.:
  @ext_css = %w(leaflet stamen)

Conditional inline styling are included via @inline_css instance variable, e.g.:
  @inline_css = [".cats .hidden {display: none;}"]
    EOS
  end

end
