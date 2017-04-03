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
    @this_dir = File.expand_path File.dirname(__FILE__)
    @app_dir = Rails.root

    msgs = []

    msgs << copy_configs
    msgs << gitignore
    msgs << gems
    msgs << facets
    msgs << stylesheet

    puts msgs.join("\n")

    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  private

  def copy_configs
    puts "Copying in configuration files"

    # initializer
    # NOTE: This could be done with the "initializer" method instead
    # http://guides.rubyonrails.org/generators.html#initializer
    FileUtils.cp("#{@this_dir}/templates/config.rb", "#{@app_dir}/config/initializers/config.rb")

    # example config file
    FileUtils.cp("#{@this_dir}/templates/config.yml", "#{@app_dir}/config/config.example.yml")

    # config file
    # does not overwrite existing config file
    if File.exist?("#{@app_dir}/config/config.yml")
      return "Verify that your config/config.yml file matches the options in config/config.example.yml".cyan
    else
      FileUtils.cp("#{@this_dir}/templates/config.yml", "#{@app_dir}/config/config.yml")
      return "Customize your app in config/config.yml".green
    end
  end

  def facets
    if !File.exist?("#{@app_dir}/app/models/facets.rb")
      puts "Copying facets.rb"
      FileUtils.cp("#{@this_dir}/../../app/models/facets.rb", "#{@app_dir}/app/models/facets.rb")
      return "Customize your facets in app/models/facets.rb".green
    else
      puts "Found existing file in facets.rb, skipping"
    end
  end

  def gems
    # remove the previous gem from Gemfile
    gsub_file "#{@app_dir}/Gemfile", /^(?!#\s)gem\s["']api_bridge["'].*$/, ""
    # install the correct version of the gem
    gem "api_bridge", git: "https://github.com/CDRH/api_bridge", version: "0.0.1"
  end

  def gitignore
    puts "Copying .gitignore file"

    # if gitignore exists, create example file
    if File.exist?("#{@app_dir}/.gitignore")
      FileUtils.cp("#{@this_dir}/templates/.gitignore", "#{@app_dir}/.gitignore_example")
      return "Verify that your .gitignore file matches the options in .gitignore_example".cyan
    else
      FileUtils.cp("#{@this_dir}/templates/.gitignore", "#{@app_dir}/.gitignore")
      return "Add more files to .gitignore which should not be version controlled".green
    end
  end

  def stylesheet
    stylesheet_path = "app/assets/stylesheets/cdrh-bootstrap-variables.scss"
    if !File.exist?("#{@app_dir}/#{stylesheet_path}")
      FileUtils.cp("#{@this_dir}/../../#{stylesheet_path}", "#{@app_dir}/#{stylesheet_path}")
      return "Customize your stylesheet in #{stylesheet_path}".green
    end
  end

end
