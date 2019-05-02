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
      if ApiBridge.is_url?(url)
        @url = url
        @facet_fields = facets
        options = _remove_rows(options)
        @options = ApiBridge.override_options(@@default_options, options)
        @options["facet"] = facets
      else
        raise "Provided URL must be valid! #{url}"
      end
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
      encoded = ApiBridge.encode(url)
      if ApiBridge.is_url?(encoded)
        encoded
      else
        raise "Invalid URL created for query: #{encoded}"
      end
    end

    # return a response instance for a particular item id
    def get_item_by_id(id)
      url = create_item_url(id)
      res = send_request(url)
      ApiBridge::Response.new(res, url, { "id" => id })
    end

    # pass through parameters to query API and receive response object
    def query(options={})
      options = _prepare_options(options)
      # override defaults with requested options
      req_params = ApiBridge.override_options(@options, options)
      # create and send the request
      url = create_items_url(req_params)
      res = send_request(url)
      # return response format
      ApiBridge::Response.new(res, url, req_params)
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

    private

    # set the start index based on page, start, and num requested parameters
    def _calc_start(options)
      # if start is specified by user then don't override with page
      page = ApiBridge.set_page(options["page"])
      # remove page from options
      options.delete("page")
      if !options.key?("start")
        # use the page and rows to set a start, use default is no num specified
        num = options.key?("num") ? options["num"].to_i : @options["num"].to_i
        options["start"] = ApiBridge.get_start(page, num)
      end
      options
    end

    # clone parameters and then remove / manipulate
    def _prepare_options(options)
      opts = ApiBridge.clone_and_stringify_options(options)
      # remove parameters which rails adds
      opts.delete("controller")
      opts.delete("action")
      opts.delete("utf8")
      opts.delete("commit")
      opts = _remove_rows(opts)
      # remove page and replace with start
      opts = _calc_start(opts)
      # remove .year from the middle of date filters for api's sake
      opts["f"].map { |f| f.slice!(".year") } if opts.has_key?("f")
      opts
    end

    # rows is a deprecated option, please use num instead
    # still supporting for backwards compatibility
    def _remove_rows(opts={})
      if opts.key?("rows")
        opts["num"] = opts["rows"] if !opts.key?("num")
        opts.delete("rows")
      end
      opts
    end

  end

end
