require 'json'
require 'net/http'
require 'uri'

module ApiBridge

  class Query
    attr_accessor :url
    attr_accessor :facet_fields
    attr_accessor :options

    # acceptable for cdrh api
    # TODO unused currently, use as filter to remove unwanted?
    @@all_options = %w(
      f,
      facet,
      facet_sort
      hl,
      min,
      num,
      page,
      q,
      sort,
      start,
    )

    # assumed options upon app startup
    @@default_options = {
      "num" => 50,
      "start" => 0,
      "facet" => []
    }

    # create a new query instance with some default settings
    def initialize(url, facets=[], options={})
      if is_url?(url)
        @url = url
        @facet_fields = facets
        options = remove_rows(options)
        @options = override_options(@@default_options, options)
        @options["facet"] = facets
      else
        raise "Provided URL must be valid! #{url}"
      end
    end

    # set the start index based on page, start, and num requested parameters
    def calc_start(options)
      # if start is specified by user then don't override with page
      page = set_page(options["page"])
      # remove page from options
      options.delete("page")
      if !options.key?("start")
        # use the page and rows to set a start, use default is no num specified
        num = options.key?("num") ? options["num"].to_i : @options["num"].to_i
        options["start"] = get_start(page, num)
      end
      options
    end

    # create a version of the request parameters to manipulate
    # without modifying the original set
    def clone_and_stringify_options(aOpts)
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

    # url to retrieve a single item
    def create_item_url(id)
      "#{@url}/item/#{id}"
    end

    # url to retrieve multiple items with a query
    def create_items_url(options={})
      # Note: URI has encode_www_form method which nearly
      # can be used, except that it doesn't add [] after
      # arrays, so rails will not parse all of the information
      query = []
      options.each do |k, v|
        if v.class == Array
          v.each do |item|
            query << "#{k}[]=#{item}"
          end
        else
          query << "#{k}=#{v}"
        end
      end
      query_string = query.join("&")
      url = "#{@url}/items?#{query_string}"
      encoded = encode(url)
      if is_url?(encoded)
        encoded
      else
        raise "Invalid URL created for query: #{encoded}"
      end
    end

    # encode the parameters of the URL
    def encode(url)
      # Split components of URL so we may encode only the query string
      request_url, query = url.split("?")
      if query
        encoded = encode_query_params(query)
        request_url << "?#{encoded}"
      end
      request_url
    end

    # crudely split query parameters and encode
    # TODO determine when a parameter includes a ? in the string
    def encode_query_params(query_string)
      # puts "QUERY_STRING: #{query_string}"
      query_string.split(/[&]/).map { |param|
        name, value = param.split("=")

        "#{name}=#{URI.encode_www_form_component(value)}"
      }.join("&")
    end

    # return a response instance for a particular item id
    def get_item_by_id(id)
      url = create_item_url(id)
      res = send_request(url)
      ApiBridge::Response.new(res, url, { "id" => id })
    end

    # calculate the result start number to request based on the page
    # and number of results per page currently set
    def get_start(page, num)
      (page - 1) * num
    end

    # check if a particular string is a valid url
    def is_url?(url)
      # rely on uri gem to do the heavy lifting
      result = url =~ /\A#{URI::Parser.new.make_regexp(['http', 'https'])}\z/
      # convert to boolean
      !!result
    end

    # given an existing set of options and a requested set of options
    # combine them and overwrite any existing with the requested
    def override_options(existing, requested)
      existing = clone_and_stringify_options(existing)
      requested = clone_and_stringify_options(requested)
      existing.merge(requested)
    end

    # clone parameters and then remove / manipulate
    def prepare_options(options)
      opts = clone_and_stringify_options(options)
      # remove parameters which rails adds
      opts.delete("controller")
      opts.delete("action")
      opts.delete("utf8")
      opts.delete("commit")
      opts = remove_rows(opts)
      # remove page and replace with start
      opts = calc_start(opts)
      # remove .year from the middle of date filters for api's sake
      opts["f"].map { |f| f.slice!(".year") } if opts.has_key?("f")
      opts
    end

    # pass through parameters to query API and receive response object
    def query(options={})
      options = prepare_options(options)
      # override defaults with requested options
      req_params = override_options(@options, options)
      # create and send the request
      url = create_items_url(req_params)
      res = send_request(url)
      # return response format
      ApiBridge::Response.new(res, url, req_params)
    end

    # rows is a deprecated option, please use num instead
    # still supporting for backwards compatibility
    def remove_rows(opts={})
      if opts.key?("rows")
        opts["num"] = opts["rows"] if !opts.key?("num")
        opts.delete("rows")
      end
      opts
    end

    # GET request
    def send_request(url)
      begin
        Rails.logger.info("sending request to #{url}")
        res = Net::HTTP.get_response(URI(url))
        JSON.parse(res.body)
      rescue => e
        raise "Something went wrong with request to #{url}: #{e.inspect}"
      end
    end

    # check if the requested page is valid, if not default to 1
    def set_page(page)
      new_page = 1
      if !page.nil?
        is_pos_num = /\A\d+\z/.match(page)
        if is_pos_num
          new_page = page.to_i
        end
      end
      new_page
    end

  end

end
