module ApiBridge

  class Response
    attr_reader :req_opts
    attr_reader :req_url
    attr_reader :res

    def initialize res, url, options
      @req_opts = options
      @req_url = url
      @res = res
    end

    def count
      @res.dig("res", "count")
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

    def pages
      ApiBridge.calculate_page self.count, @req_opts["num"]
    end
  end

end
