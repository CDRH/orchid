require 'json'
require 'net/http'
require 'uri'

module ApiBridge

  class Query
    attr_accessor :url
    attr_accessor :app_facets
    attr_accessor :app_options

    # assumed options upon app startup
    @@orchid_default_options = { "num" => 50 }

    # create a new query instance with some default settings
    def initialize(url, facets=[], options={})
      if is_url?(url)
        @url = url
        options = remove_rows(options)
        # override the orchid defaults with the app query defaults
        @app_options = @@orchid_default_options.clone.merge(options)
        # make app default facets available via accessor
        # and add to the app default request options as well
        @app_facets = facets
        # singular because API ultimately expects facet[]=...
        @app_options["facet"] = facets
      else
        raise "Provided URL must be valid! #{url}"
      end
    end

    # set the start index based on page, start, and num requested parameters
    # is start is specified, it overrides page
    def calc_start(options)
      # set the page to 1 if the requested parameter is not valid and then remove page
      page = set_page(options["page"])
      options.delete("page")
      if !options.key?("start")
        # use the page and rows to set a start, use default is no num specified
        num = options.key?("num") ? options["num"].to_i : @app_options["num"].to_i
        options["start"] = (page - 1) * num
      end
      options
    end

    # url to retrieve a single item
    def create_item_url(id)
      File.join(@url, "item", id)
    end

    # url to retrieve multiple items with a query
    def create_items_url(options={})
      # Note: URI has encode_www_form method which nearly
      # can be used, except that it doesn't add [] after
      # arrays, so rails will not parse all of the information
      query = []
      options.each do |k, v|
        if v.class == Array
          v.each { |item| query << "#{k}[]=#{item}" }
        else
          query << "#{k}=#{v}"
        end
      end
      query = query.map { |q| encode_param(q) }
      query_string = query.join("&")
      url = "#{@url}/items?#{query_string}"
      if is_url?(url)
        url
      else
        raise "Invalid URL created for query: #{url}"
      end
    end

    def encode_param(param)
      key, value = param.split("=")
      "#{key}=#{URI.encode_www_form_component(value)}"
    end

    # return a response instance for a particular item id
    def get_item_by_id(id)
      url = create_item_url(id)
      res = send_request(url)
      ApiBridge::Response.new(res, url, { "id" => id })
    end

    # check if a particular string is a valid url
    def is_url?(url)
      # rely on uri gem to do the heavy lifting
      result = url =~ /\A#{URI::Parser.new.make_regexp(['http', 'https'])}\z/
      # convert to boolean
      !!result
    end

    # create a version of the request parameters to manipulate
    # without modifying the original set
    # the incoming parameters can either be a hash built in the controller
    # or parameters passed directly through
    def params_to_hash(options)
      opts_hash = {}
      if options.class == Hash
        opts_hash = options.clone
      elsif options.class == ActionController::Parameters
        # TODO only allow through "safe" params and convert to hash
        opts_hash = options.deep_dup.to_unsafe_h
      end
      # ensure that there are no symbols hiding in there
      Hash[opts_hash.map { |k, v| [k.to_s, v] }]
    end

    # clone parameters or hash array and then remove / manipulate for api
    def prepare_options(options)
      # combine the incoming params with the app default options
      params_hash = params_to_hash(options)
      opts = @app_options.clone.merge(params_hash)
      # remove rails specific parameters and reassign "rows"
      %w[action commit controller utf8].each { |p| opts.delete(p) }
      opts = remove_rows(opts)
      # remove page and replace with start
      opts = calc_start(opts)
      # remove .year from the middle of date filters for api's sake which
      # automatically adds Jan 1 and Dec 31 to incoming date strings of years
      opts["f"].map { |f| f.slice!(".year") } if opts.has_key?("f")
      opts
    end

    # pass through parameters to query API and receive response object
    def query(request_options={})
      options = prepare_options(request_options)
      # create and send the request
      url = create_items_url(options)
      res = send_request(url)
      # return response format
      ApiBridge::Response.new(res, url, options)
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
      page.nil? || !/\A[1-9]\d*\z/.match(page) ? 1 : page.to_i
    end

  end

end
