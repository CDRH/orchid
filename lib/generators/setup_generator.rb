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
    msgs << gitignore
    msgs << gems
    msgs << facets
    msgs << stylesheet
    msgs << remove_files

    Bundler.with_clean_env do
      run "bundle install"
    end

    puts msgs.compact.join("\n")

  end

  private

  def copy_configs
    # example config file
    FileUtils.cp("#{@this_app}/lib/generators/templates/config.yml", "#{@new_app}/config/config.example.yml")

    # config file
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

  def gems

    # bootstrap
    gem 'bootstrap-sass', '~> 3.3.6'

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
    # application_controller
    FileUtils.rm("#{@new_app}/app/controllers/application_controller.rb")
    # layout
    FileUtils.rm("#{@new_app}/app/views/layouts/application.html.erb")
  end

  def stylesheet
    # variables
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss", "#{@new_app}/app/assets/stylesheets/cdrh-bootstrap-variables.scss")

    # sub application.css for scss with variables
    FileUtils.rm("#{@new_app}/app/assets/stylesheets/application.css")
    FileUtils.cp("#{@this_app}/app/assets/stylesheets/application.scss", "#{@new_app}/app/assets/stylesheets/application.scss")

    return "Customize your stylesheet in app/assets/stylseheets/cdrh-bootstrap-variables.scss".green
  end

end
