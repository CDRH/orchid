module ApplicationHelper
  include Orchid::ApplicationHelper

  def parse_md_brackets(query)
    /\[(.*)\]/.match(query)[1] if /\[(.*)\]/.match(query)
  end

  def parse_md_parentheses(query)
    /\]\((.*)\)/.match(query)[1] if /\]\((.*)\)/.match(query)
  end
end
