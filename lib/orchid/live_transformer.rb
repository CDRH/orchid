class LiveTransformer

  def self.transform(id, location)
    if Rails.env != "production"
      about = "didn't set about"
      path = "/Users/jdussault2/Desktop/repos/collections/family_letters"
      # Dir.chdir(path) {
      #   about = %x[ls -al]
      # }
      %x[cd #{path} && bundle exec about]
    else
      # TODO figure that out later
      "Unable to obtain item HTML with current production settings"
    end
  end

end
