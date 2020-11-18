class SetupGenerator < Rails::Generators::Base

  desc "Friendly warning that 'setup' is not longer supported"

  def deprecation
    puts "\nDid you mean `rails g orchid_setup` ?"
  end

end
