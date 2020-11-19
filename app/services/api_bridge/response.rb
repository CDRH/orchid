module ApiBridge

  class Response
    attr_reader :req_opts
    attr_reader :req_url
    attr_reader :res

    def initialize(res, url, options)
      @req_opts = options
      @req_url = url
      @res = res
    end

    def count
      @res.dig("res", "count", "value")
    end

    def error
      @res.dig("error")
    end

    def error
      @res.dig("error")
    end

    def facets
      @res.dig("res", "facets")
    end

    def items
      @res.dig("res", "items")
    end

    def first
      @res.dig("res", "items", 0)
    end

    # given the total number of results and the number requested per page
    # calculate the total number of pages of results
    def pages
      num = @req_opts["num"]
      self.count && num ? (self.count.to_f/num.to_i).ceil : 1
    end
  end

end
