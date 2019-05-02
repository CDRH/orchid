require 'json'
require 'net/http'
require 'uri'

module ApiBridge

  class Query
    attr_accessor :url
    attr_accessor :facet_fields
    attr_accessor :options

    @@all_options = %w(q, f, facet, hl, min, num, q, sort, page, start, facet_sort)

    @@default_options = {
      "num" => 50,
      "start" => 0,
      "facet" => []
    }

    def initialize url, facets=[], options={}
      if ApiBridge.is_url?(url)
        @url = url
        # defaults
        # TODO how to incorporate facets here and facets from request
        # into query?  See also: f[] field
        @facet_fields = facets
        options = _remove_rows(options)
        @options = override_options options
        @options["facet"] = facets
      else
        raise "Provided URL must be valid! #{url}"
      end
    end

    def create_item_url id
      return "#{@url}/item/#{id}"
    end

    def create_items_url options={}
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
        return encoded
      else
        raise "Invalid URL created for query: #{encoded}"
      end
    end

    def get_item_by_id id
      url = create_item_url id
      res = send_request url
      return ApiBridge::Response.new(res, url, { "id" => id })
    end

    # overrides the CURRENTLY SET options, not the vanilla default options
    def override_options requested
      existing = defined?(@options) ? @options : @@default_options
      @options = ApiBridge.override_options(existing, requested)
    end

    def reset_options
      @options = @@default_options.clone
    end

    def query options={}
      _query options
    end

    def send_request url
      begin
        Rails.logger.info("sending request to #{url}")
        res = Net::HTTP.get_response(URI(url))
        return JSON.parse(res.body)
      rescue => e
        raise "Something went wrong with request to #{url}: #{e.inspect}"
      end
    end

    private

    def _calc_start options
      # if start is specified by user then don't override with page
      page = ApiBridge.set_page(options["page"])
      # remove page from options
      options.delete("page")
      if !options.key?("start")
        # use the page and rows to set a start, use default is no num specified
        num = options.key?("num") ? options["num"].to_i : @options["num"].to_i
        options["start"] = ApiBridge.get_start(page, num)
      end
      return options
    end

    def _prepare_options options
      opts = ApiBridge.clone_and_stringify_options(options)
      # remove parameters which rails adds
      opts.delete("controller")
      opts.delete("action")
      opts.delete("utf8")
      opts.delete("commit")
      opts = _remove_rows(opts)
      # remove page and replace with start
      opts = _calc_start opts
      # remove .year from the middle of date filters for api's sake
      opts["f"].map { |f| f.slice!(".year") } if opts.has_key?("f")
      # add escapes for special characters
      opts = ApiBridge.escape_values(opts)
      return opts
    end

    def _query options={}
      options = _prepare_options options
      # override defaults with requested options
      req_params = ApiBridge.override_options(@options, options)
      # create and send the request
      url = create_items_url req_params
      res = send_request url
      # return response format
      return ApiBridge::Response.new(res, url, req_params)
    end

    def _remove_rows opts={}
      if opts.key?("rows")
        opts["num"] = opts["rows"] if !opts.key?("num")
        opts.delete("rows")
      end
      opts
    end

  end

end
