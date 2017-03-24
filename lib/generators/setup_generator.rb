require "colorize"

class SetupGenerator < Rails::Generators::Base

  desc <<-EOS
    This generator prepares applications for API integration:
      1. Generates config/config.yml file
      2. Sets up empty directory structure for overrides
      3. Sets up default stylesheet variables file
  EOS

  def setup_files
    @this_dir = File.expand_path File.dirname(__FILE__)
    @app_dir = Rails.root

    copy_configs
    gitignore
  end

  private

  def copy_configs
    puts "Copying in configuration files".green
    # initializer
    FileUtils.cp("#{@this_dir}/templates/config.rb",
                 "#{@app_dir}/config/initializers/config.rb"
                )

    # example config file
    FileUtils.cp("#{@this_dir}/templates/config.yml",
                 "#{@app_dir}/config/config.example.yml"
                )

    # config file
    # does not overwrite existing config file
    if File.exist?("#{@app_dir}/config/config.yml")
      puts "Verify that your config/config.yml file matches the options in config/config.example.yml".red
    else
      FileUtils.cp("#{@this_dir}/templates/config.yml",
                   "#{@app_dir}/config/config.yml"
                  )
      puts "Customize your app in config/config.yml"
    end
  end

  def gitignore
    # insert several lines into .gitignore file or initialize if not there
  end

end
