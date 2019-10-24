module Orchid::DateHelper

  def clear_dates_params
    new_params = copy_params
    new_params.delete("date_from")
    new_params.delete("date_to")
    # Remove page to return to first page of reorganized results
    new_params.delete("page")
    new_params
  end

  # TODO could abstract this into a CDRH gem
  def date_default(date_params, default_date)
    y, m, d = date_params.map { |x| x.strip }
    y = default_date[0] if y.blank?
    m = default_date[1] if m.blank?
    d = default_date[2] if d.blank?

    "#{y}-#{m}-#{d}"
  end

  def date_present? date
    return Array(date).reject(&:empty?).present?
  end

  # main method responsible for taking params and returning
  # a set of options for querying the API
  # assumes that options is a hash, NOT params object
  def date_filter options
    # date search
    if date_present?(options["date_from"]) || date_present?(options["date_to"])
      from, to = date_set(options["date_from"], options["date_to"])
      options["f"] = [] if !options.key?("f")
      options["f"] << "date|#{from}|#{to}"
    end
    options.delete("date_from")
    options.delete("date_to")
    [options, from, to]
  end

  def date_format(date)
    y, m, d = date.split("-")

    # Fix numbers out of range
    y = 1 if y.to_i < 1
    y = Time.now.year if y.to_i > Time.now.year

    m = 1 if m.to_i < 1
    m = 12 if m.to_i > 12

    d = 1 if d.to_i < 1
    d = 31 if d.to_i > 31

    # pad with zeros (1 => 01)
    y = y.to_s.rjust(4, "0")
    m = m.to_s.rjust(2, "0")
    d = d.to_s.rjust(2, "0")

    "#{y}-#{m}-#{d}"
  end

  # TODO could abstract this into a CDRH gem
  # if a date is blank, use the other date in its place
  def date_overwrite(original, overwrite)
    date_present?(original) ? original : overwrite
  end

  def date_selection?(from, to)
    [from, to].each do |date|
      if date.present? && date.reject(&:empty?).present?
        return true
      end
    end
    false
  end

  # unlikely candidate to be abstracted into a gem because it
  # operates directly on the params object
  def date_set(date_from, date_to)
    # if the first parameter is empty, default to using second date instead
    date_from = date_overwrite(date_from, date_to)
    date_to = date_overwrite(date_to, date_from)

    # after date potentially duplicated above, use first/last entry years
    # and first/last day of year to cover missing year, month, and day
    date_from = date_default(date_from, [DATE_FIRST[0], "01", "01"])
    date_to = date_default(date_to, [DATE_LAST[0], "12", "31"])

    date_from = date_format(date_from)
    date_to = date_format(date_to)

    # Set parameters so form populated with calculated dates
    params[:date_from] = date_from.split("-")
    params[:date_to] = date_to.split("-")

    [date_from, date_to]
  end

end
