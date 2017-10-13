module Orchid::SortHelper

  def sort(typedir)
    # typedir expected to be field|direction
    new_params = copy_params
    new_params["sort"] = [typedir]
    new_params.delete("page")
    return new_params
  end

  def sorter
    sort_by = ""

    if params["sort"].blank?
      if params["q"].present?
        sort_by = "relevancy|desc"
      else
        sort_by = API_OPTS["sort"].present? ? API_OPTS["sort"] : "title|asc"
      end
    else
      sort_by = params["sort"]
    end

    # Pull value out of single-element array
    sort_by = sort_by.first if sort_by.class == Array

    render "sort", sort_by: sort_by
  end

  def sort_fields_facets
    # include "grouping" => "separator" to insert separator in dropdown
    {
      "count|desc" => "Count (most first)",
      "count|asc" => "Count (least first)",

      "terms" => "separator",
      "term|asc" => "Alphabetically (A-Z)",
      "term|desc" => "Alphabetically (Z-A)"
    }
  end

  def sort_fields_search
    if params["q"].present?
      fields = {
        "relevancy|desc" => "Relevancy",
        "rel_separator" => "separator"
      }
    else
      fields = {}
    end

    fields.merge(sort_fields_search_additional)
  end

  def sort_fields_search_additional
    # include "grouping" => "separator" to insert separator in dropdown
    {
      "date|asc" => "Date (earliest first)",
      "date|desc" => "Date (latest first)",

      "titles" => "separator",
      "title|asc" => "Title (A-Z)",
      "title|desc" => "Title (Z-A)",

      "creators" => "separator",
      "creator.name|asc" => "Creator (A-Z)",
      "creator.name|desc" => "Creator (Z-A)"
    }
  end

  def sort_selected_label(sort_fields, sort_by)
    if respond_to? "sort_fields_#{sort_fields}"
      sort_fields = send "sort_fields_#{sort_fields}"
    else
      raise "#{sort_fields} is not an existing sort fields hash"
    end

    if sort_by == "relevancy|desc"
      "Relevancy"
    elsif sort_fields.keys.include?(sort_by)
      sort_fields[sort_by]
    else
      sort_by
    end
  end

end
