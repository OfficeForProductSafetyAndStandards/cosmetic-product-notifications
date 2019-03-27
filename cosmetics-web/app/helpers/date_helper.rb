module DateHelper
  def display_full_month_date date
    date.strftime("%-d %B %Y")
  end

  def display_date date
    date.strftime("%d/%m/%Y")
  end
end
