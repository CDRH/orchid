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

    puts msgs.compact.join("\n")

  end

  private

  def copy_configs
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.yml", "#{@new_app}/config/config.example.yml")
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.yml", "#{@new_app}/config/config.yml")

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

  def remove_files
    # This causes the new app to use Orchid's corresponding files
    FileUtils.rm("#{@new_app}/app/controllers/application_controller.rb")
    FileUtils.rm("#{@new_app}/app/views/layouts/application.html.erb")
  end

  def scripts
    FileUtils.cp("#{@this_app}/app/assets/javascripts/application.js", "#{@new_app}/app/assets/javascripts/application.js")
    FileUtils.cp("#{@this_app}/app/assets/javascripts/search.js", "#{@new_app}/app/assets/javascripts/search.js")

    # Create directory for auto-included app-wide JavaScript
    FileUtils.mkdir("#{@new_app}/app/assets/javascripts/global")

    return "Add app-wide JavaScript to app/assets/javascripts/global/\nAll .js file contents there are served with every page\n\nView-specific JS is to be added to @extra_js instance variable, e.g.:\n  @extra_js = [javascript_include_tag(\"search\")]".green
  end

  def stylesheet
    # Bootstrap variable overrides
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss", "#{@new_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss")

    # Must use application.scss for mixins and variables
    FileUtils.rm("#{@new_app}/app/assets/stylesheets/application.css")
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/application.scss", "#{@new_app}/app/assets/stylesheets/application.scss")

    return "Customize Bootstrap in app/assets/stylseheets/cdrh-bootstrap-variables.scss\nApplication-wide styling to be added via application.scss\n\nView-specific styling to be added to @extra_css instance variable, e.g.:\n  @extra_css = [stylesheet_link_tag(\"leaflet\")]".green
  end

end
