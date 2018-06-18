require "net/http"
require "json"
require "open-uri"

namespace :data_import do
  desc "Import product data from RAPEX"
  task rapex: :environment do
    weekly_reports = rapex_weekly_reports
    previously_imported_reports = RapexImport.all
    weekly_reports.each do |report|
      reference = report.xpath("reference").text
      unless imported_reports_contains_reference(previously_imported_reports, reference)
        import_report(report)
        RapexImport.create(reference: reference)
      end
    end
  end
end

def import_report(report)
  reference = report.xpath("reference").text
  puts "Importing #{reference}"
  url = report.xpath("URL").text.delete("\n")
  notifications(url).each do |notification|
    create_product notification
  end
end

def create_product(notification)
  Product.create(
    gtin: barcode_from_notification(notification),
    name: field_from_notification(notification, "product"),
    description: field_from_notification(notification, "description"),
    model: field_from_notification(notification, "type_numberOfModel"),
    batch_number: field_from_notification(notification, "batchNumber_barcode"),
    brand: field_from_notification(notification, "brand"),
    image_url: first_picture_url(notification)
  )
end

def barcode_from_notification(notification)
  regex = /(\d{1}\s?-?\d{6}\s?-?\d{6})/
  batch_barcode = field_from_notification(notification, "batchNumber_barcode")
  barcode = batch_barcode[regex, 1]
  barcode = barcode.tr("-", "").tr(" ", "") unless barcode.nil?
  barcode
end

def first_picture_url(notification)
  field_from_notification(notification, "pictures/picture")
end

def field_from_notification(notification, field_name)
  field = notification.xpath(field_name)[0]
  field = field.text.delete("\n") unless field.nil?
  field
end

def notifications(url)
  puts "Fetching from #{url}"
  xml = Nokogiri::XML(download_url(url))
  xml.xpath("//notification")
end

def rapex_weekly_reports
  xml = Nokogiri::XML(
    download_url(
      "https://ec.europa.eu/consumers/consumers_safety/safety_products/rapex/alerts/?event=main.weeklyReports.XML"
    )
  )
  xml.xpath("//weeklyReport")
end

def download_url(url)
  uri = URI(url)
  uri.open
end

def imported_reports_contains_reference(reports, reference)
  reports.any? { |report| report.reference.casecmp(reference).zero? }
end
