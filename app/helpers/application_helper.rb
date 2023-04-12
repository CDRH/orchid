module ApplicationHelper
  include Orchid::ApplicationHelper

  def parse_md_brackets(query)
    # check if brackets match, otherwise return the original query
    if /\[(.*?)\]/.match(query)
      /\[(.*?)\]/.match(query)[1]
    else
      query
    end
  end

  def parse_md_parentheses(query)
    /\]\((.*)\)/.match(query)[1] if /\]\((.*)\)/.match(query)
  end
end
