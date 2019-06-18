module DateHelper
  def display_full_time_and_date(date)
    "#{display_time(date)} on #{display_full_month_date(date)}"
  end

  def display_full_month_date(date)
    date.strftime("%-d %B %Y")
  end

  def display_date(date)
    date.strftime("%d/%m/%Y")
  end

  def display_time(date)
    date.strftime("%l\u200A%P")
  end
end
