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
      elsif defined?(SECTIONS) && SECTIONS.dig(@section, "api_options", "sort")
        sort_by = SECTIONS[@section]["api_options"]["sort"]
      else
        sort_by = API_OPTS["sort"].present? ? API_OPTS["sort"] : "title|asc"
      end
    else
      sort_by = params["sort"]
    end

    # Pull value out of single-element array
    sort_by = sort_by.first if sort_by.class == Array

    render_overridable("items", "sort", sort_by: sort_by)
  end

  def sort_fields_facets
    if @section.present? && respond_to?("#{@section}_sort_fields_facets")
      send "#{@section}_sort_fields_facets"
    else
      # include "grouping" => "separator" to insert separator in dropdown
      {
        "count|desc" => t("search.sort.count_desc", default: "Count (most first)"),
        "count|asc" => t("search.sort.count_asc", default: "Count (least first)"),

        "terms" => "separator",
        "term|asc" => t("search.sort.alpha_asc", default: "Alphabetically (A-Z)"),
        "term|desc" => t("search.sort.alpha_desc", default: "Alphabetically (Z-A)")
      }
    end
  end

  def sort_fields_search
    if @section.present? && respond_to?("#{@section}_sort_fields_search")
      send "#{@section}_sort_fields_search"
    else
      if params["q"].present?
        fields = {
          "relevancy|desc" => t("search.sort.relevancy", default: "Relevancy"),
          "rel_separator" => "separator"
        }
      else
        fields = {}
      end

      fields.merge(sort_fields_search_additional)
    end
  end

  def sort_fields_search_additional
    if @section.present? && respond_to?("#{@section}_sort_fields_search_additional")
      send "#{@section}_sort_fields_search_additional"
    else
      # include "grouping" => "separator" to insert separator in dropdown
      {
        "date|asc" => t("search.sort.date_asc", default: "Date (earliest first)"),
        "date|desc" => t("search.sort.date_desc", default: "Date (latest first)"),

        "titles" => "separator",
        "title_sort|asc" => t("search.sort.title_asc", default: "Title (A-Z)"),
        "title_sort|desc" => t("search.sort.title_desc", default: "Title (Z-A)"),

        "creators" => "separator",
        "creator.name|asc" => t("search.sort.creator_asc", default: "Creator (A-Z)"),
        "creator.name|desc" => t("search.sort.creator_desc", default: "Creator (Z-A)")
      }
    end
  end

  def sort_selected_label(sort_fields, sort_by)
    if respond_to? "sort_fields_#{sort_fields}"
      sort_fields = send "sort_fields_#{sort_fields}"
    else
      raise "#{sort_fields} is not an existing sort fields hash"
    end

    if sort_by == "relevancy|desc"
      t("search.sort.relevancy", default: "Relevancy")
    elsif sort_fields.keys.include?(sort_by)
      sort_fields[sort_by]
    else
      sort_by
    end
  end

end
