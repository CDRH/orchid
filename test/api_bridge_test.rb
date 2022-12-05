require 'test_helper'

class Orchid::Test < ActiveSupport::TestCase
  # Note: order of test assert_equal is "expected" and "actual"

  def before_setup
    super
    @f_app = ["collection|letters", "keyword|production"]
    @facet_app = ["creator.name", "date.year", "category2"]
    @api = ApiBridge::Query.new("https://test.unl.edu/v1",
      @facet_app,
      { "num" => 5, "sort" => "title|asc", "f" => @f_app }
    )
  end

  test "initialization" do
    # bad url
    assert_raises do
      ApiBridge::Query.new("bad_url")
    end

    # no options
    api = ApiBridge::Query.new("https://validurl.unl.edu/v1")
    assert api
    assert_equal [], api.app_facets
    assert_equal({ "num" => 50, "facet" => [] }, api.app_options)

    # override options
    assert_equal @facet_app, @api.app_facets
    assert_equal(
      {
        "num" => 5,
        "sort" => "title|asc",
        "f" => @f_app,
        "facet" => @facet_app
      },
      @api.app_options
    )

    # preference incoming rows over default num
    api = ApiBridge::Query.new("https://validurl.unl.edu/v1", [], { "rows" => "2" })
    assert_equal "2", api.app_options["num"]
  end

  test "calc_start" do
    # setting pages and nums
    opts = @api.calc_start({"page" => "2", "num" => "3"})
    assert_equal 3, opts["start"]
    opts = @api.calc_start({"page" => "10", "num" => "50"})
    assert_equal 450, opts["start"]
    # no page set
    opts = @api.calc_start({"num" => "20"})
    assert_equal 0, opts["start"]
    # illegal page
    opts = @api.calc_start({"page" => "-1", "num" => "10"})
    assert_equal 0, opts["start"]
  end

  test "create_item_url" do
    url = @api.create_item_url("cat.let1728")
    assert_equal "https://test.unl.edu/v1/item/cat.let1728", url
  end

  test "create_items_url" do
    # just a facet
    url = @api.create_items_url({ "facet" => ["date.year", "source"] })
    assert_equal "https://test.unl.edu/v1/items?facet[]=date.year&facet[]=source", url
    # a filter that needs some encoding
    url = @api.create_items_url({ "f" => ["creator.name|\"Yosemite Sam\": Worst Name Ever"]})
    assert_equal "https://test.unl.edu/v1/items?f[]=creator.name%7C%22Yosemite+Sam%22%3A+Worst+Name+Ever", url
    # a bunch of things
    url = @api.create_items_url({ "q" => "text:water", "hl_num" => "3", "f" => ["category|Writings"]})
    assert_equal "https://test.unl.edu/v1/items?q=text%3Awater&hl_num=3&f[]=category%7CWritings", url
  end

  test "encode_param" do
    # no particularly unusual characters
    param = @api.encode_param("f[]=source|UNL Special Collections")
    assert_equal "f[]=source%7CUNL+Special+Collections", param
    # ampersand!
    param = @api.encode_param("f[]=repository|Archives & Special Collections")
    assert_equal "f[]=repository%7CArchives+%26+Special+Collections", param
    # numbers
    param = @api.encode_param("facet[]=date.year|1867")
    assert_equal "facet[]=date.year%7C1867", param
  end

  # get_item_by_id

  test "is_url?" do
    # definitely not
    assert_not @api.is_url?("some string")
    # sort of but not quite!
    assert_not @api.is_url?("test.unl.edu")
    # http
    assert @api.is_url?("http://test.unl.edu")
    # https
    assert @api.is_url?("https://test.unl.edu")
    # port and path
    assert @api.is_url?("http://localhost:3000/api/v1/items")
  end

  test "params_to_hash" do
    # make sure this hash is not altered and returns only as string keys
    original = { "a" => 1, b: 2 }
    cloned = @api.params_to_hash(original)
    assert_includes cloned, "b"
    assert_not_includes cloned, :b
    cloned.delete("a")
    assert_includes original, "a"
    # Same checks for ActionController::Parameters object
    original = ActionController::Parameters.new({ "a" => 1, b: 2 })
    cloned = @api.params_to_hash(original)
    assert_includes cloned, "b"
    assert_not_includes cloned, :b
    cloned.delete("a")
    assert_includes original, "a"
  end

  test "prepare_options" do
    # make sure rows overrides num when also sent in
    # (@api created with num)
    opts = @api.prepare_options({ "rows" => "20" })
    assert_not_includes opts, "rows"
    assert_equal "20", opts["num"]

    # make sure to remove rails stuff
    req_opts = ActionController::Parameters.new({
      controller: "items", action: "index", utf8: "✓", q: "water"
    })
    res_opts = {
      "num" => 5,
      "sort" => "title|asc",
      "f" => @f_app,
      "facet" => @facet_app,
      "q" => "water",
      "start" =>
      0
    }
    assert_equal res_opts, @api.prepare_options(req_opts)

    # calculate the start when nothing sent specifically about it
    assert_equal 0, @api.prepare_options({})["start"]

    # calculate the start when something IS sent in about it
    assert_equal 8, @api.prepare_options({ "num" => "2", "page" => "5" })["start"]
    assert_equal 20, @api.prepare_options({ "num" => "20", "page" => "2" })["start"]
  end

  test "prepare_options f[]" do
    # check that there is a filter applied in the app wide settings
    assert_equal @f_app, @api.prepare_options({})["f"]

    # set a new filter which is not the same as the app wide filter
    assert_equal(
      @f_app + ["category2|memos"],
      @api.prepare_options({ "f" => ["category2|memos"] })["f"]
    )

    # check that filter collisions preference the request
    assert_equal(
      [
        "collection|letters",
        "keyword|development",
        "keyword|in_review",
        "category2|marginalia"
      ],
      @api.prepare_options({
        "f" => [
          "keyword|development",
          "keyword|in_review",
          "category2|marginalia"
        ]
      })["f"]
    )
  end

  test "prepare_options facet[]" do
    # check that requested facets completely override default facets
    assert_equal @facet_app, @api.prepare_options({})["facet"]
    assert_equal(
      ["category", "person.name"],
      @api.prepare_options({ "facet" => ["category", "person.name"] })["facet"]
    )
  end

  test "query" do
    skip("skipping integration testing")
  end

  test "remove_rows" do
    # rows always overrides num....for now!
    opts = { "rows" => "5", "num" => "10" }
    assert_equal({ "num" => "5"}, @api.remove_rows(opts))
  end

  test "send_request" do
    skip "skipping integration testing"
  end

  test "set_page" do
    # no page means page 1!
    assert_equal 1, @api.set_page(nil)
    # page can't be zero or negative, sorry
    assert_equal 1, @api.set_page("0")
    assert_equal 1, @api.set_page("00")
    assert_equal 1, @api.set_page("-1")
    # no leading zeroes, please
    assert_equal 1, @api.set_page("09")
    # page has to be some type of number
    assert_equal 1, @api.set_page("one")
    # valid pages should come back as integers
    assert_equal 2, @api.set_page("2")
    assert_equal 10, @api.set_page("10")
    assert_equal 1024, @api.set_page("1024")
  end

end
