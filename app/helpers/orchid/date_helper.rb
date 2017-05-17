module Orchid::DateHelper

  def clear_dates_params
    # duplicate parameters, remove date fields, and return
    options = params.permit!.deep_dup
    options.delete("date_from")
    options.delete("date_to")
    return options
  end

  # TODO could abstract this into a CDRH gem
  def date_default(date_params, default_date)
    y, m, d = date_params.map { |x| x.strip }
    y = default_date[0] if y.blank?
    m = default_date[1] if m.blank?
    d = default_date[2] if d.blank?

    # pad month and day with zeros (1 => 01)
    m = m.rjust(2, "0")
    d = d.rjust(2, "0")

    return "#{y}-#{m}-#{d}"
  end

  # main method responsible for taking params and returning
  # a set of options for querying the API
  def date_filter aParams=params
    options = params.permit!.deep_dup
    # date search
    if (!options["date_from"].nil? && !options["date_from"].join('').empty?) \
    || (!options["date_to"].nil? && !options["date_to"].join('').empty?)
      from, to = date_set(options["date_from"], options["date_to"])
      options["f"] = [] if !options.has_key?("f")
      options["f"] << "date|#{from}|#{to}"
    end
    options.delete("date_from")
    options.delete("date_to")
    return [options, from, to]
  end

  # TODO could abstract this into a CDRH gem
  # if a date is blank, use the other date in its place
  def date_overwrite(original, overwrite)
    return original.reject(&:empty?).blank? ? overwrite : original
  end

  def date_selection?(from, to)
    [from, to].each do |date|
      if date.present? && date.reject(&:empty?).present?
        return true
      end
    end
    return false
  end

  # unlikely candidate to be abstracted into a gem because it
  # operates directly on the params object
  def date_set(date_from, date_to)
    # if the first parameter is empty, then default to using the second date instead
    date_from = date_overwrite(date_from, date_to)
    date_to = date_overwrite(date_to, date_from)

    # after date potentially duplicated above, use first/last entry years
    # and first/last day of year to cover missing year, month, and day
    date_from = date_default(date_from, [DATE_FIRST[0], "01", "01"])
    date_to = date_default(date_to, [DATE_LAST[0], "12", "31"])

    # Set parameters so form populated with calculated dates
    params[:date_from] = date_from.split("-")
    params[:date_to] = date_to.split("-")

    return [date_from, date_to]
  end

end
