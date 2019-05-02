require "api_bridge/query.rb"
require "api_bridge/response.rb"

require 'uri'

module ApiBridge

  # encode the parameters of the URL
  def self.encode(url)
    # Split components of URL so we may encode only the query string
    request_url, query = url.split("?")
    if query
      encoded = encode_query_params(query)
      request_url << "?#{encoded}"
    end
    request_url
  end

  # calculate the result start number to request based on the page
  # and number of results per page currently set
  def self.get_start(page, num)
    (page - 1) * num
  end

  # create a version of the request parameters to manipulate
  # without modifying the original set
  def self.clone_and_stringify_options(aOpts)
    # if params are already a hash, leave them alone,
    # otherwise assume they are Rails parameters and convert to hash
    opts_hash = {}
    if aOpts.class == Hash
      opts_hash = aOpts.clone
    elsif aOpts.class == ActionController::Parameters
      # TODO only allow through "safe" params and convert to hash
      opts_hash = aOpts.deep_dup.to_unsafe_h
    end
    # ensure that there are no symbols hiding in there
    Hash[opts_hash.map { |k, v| [k.to_s, v] }]
  end

  # check if a particular string is a valid url
  def self.is_url?(url)
    # rely on uri gem to do the heavy lifting
    result = url =~ /\A#{URI::Parser.new.make_regexp(['http', 'https'])}\z/
    # convert to boolean
    !!result
  end

  # given an existing set of options and a requested set of options
  # combine them and overwrite any existing with the requested
  def self.override_options(existing, requested)
    existing = clone_and_stringify_options(existing)
    requested = clone_and_stringify_options(requested)
    existing.merge(requested)
  end

  # check if the requested page is valid, if not default to 1
  def self.set_page(page)
    new_page = 1
    if !page.nil?
      is_pos_num = /\A\d+\z/.match(page)
      if is_pos_num
        new_page = page.to_i
      end
    end
    new_page
  end

  private

  # crudely split query parameters and encode
  # TODO determine when a parameter includes a ? in the string
  def self.encode_query_params(query_string)
    # puts "QUERY_STRING: #{query_string}"
    query_string.split(/[&]/).map { |param|
      name, value = param.split("=")

      "#{name}=#{URI.encode_www_form_component(value)}"
    }.join("&")
  end

end
