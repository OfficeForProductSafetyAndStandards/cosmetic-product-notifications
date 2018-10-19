require "net/http"
require "json"
require "open-uri"

namespace :data_import do
  desc "Import product data from RAPEX"
  task rapex: :environment do
    weekly_reports = rapex_weekly_reports
    previously_imported_reports = RapexImport.all
    weekly_reports.reverse_each do |report|
      reference = report.xpath("reference").text
      unless imported_reports_contains_reference(previously_imported_reports, reference)
        import_report(report)
        RapexImport.create(reference: reference)
      end
    end
  end

  # this will delete products even if they are used by an investigation not from RAPEX
  task delete_rapex: :environment do
    RapexImport.all.destroy_all
    Source.where(name: "RAPEX").each do |source|
      source.sourceable.destroy
    end
  end
end

def import_report(report)
  date = Date.strptime(report.xpath("publicationDate").text, "%e/%m/%Y")
  reference = report.xpath("reference").text
  puts "Importing #{reference}"
  url = report.xpath("URL").text.delete("\n")
  notifications(url).each do |notification|
    create_records_from_notification(notification, date)
  end
end

def create_records_from_notification(notification, date)
  return nil unless (name = name_or_product(notification))

  investigation = create_investigation(notification, date, name)
  product = create_product(notification, name)
  create_product_images(notification, product) unless product.nil?
  create_investigation_product(investigation, product) unless investigation.nil? || investigation.id.nil? || product.nil?
  create_activity(notification, investigation, date) unless investigation.nil?
end

def create_product(notification, name)
  Product.where.not(gtin: "").where(gtin: barcode_from_notification(notification)).first_or_create(
    gtin: barcode_from_notification(notification),
    name: name,
    description: field_from_notification(notification, "description"),
    model: field_from_notification(notification, "type_numberOfModel"),
    product_type: field_from_notification(notification, "category"),
    batch_number: field_from_notification(notification, "batchNumber_barcode"),
    country_of_origin: field_from_notification(notification, "countryOfOrigin"),
    brand: brand(notification),
    source: ReportSource.new(name: "RAPEX")
  )
end

def create_investigation(notification, date, name)
  Investigation.create(
    title: name,
    description: field_from_notification(notification, "danger"),
    is_closed: true,
    risk_overview: field_from_notification(notification, "riskType"),
    risk_level: risk_level(notification),
    created_at: date,
    updated_at: date,
    source: ReportSource.new(name: "RAPEX")
  )
end

def create_product_images(notification, product)
  urls = notification.xpath("pictures/picture")
  urls.each do |url|
    clean_url = url.text.delete("\n") unless url.nil?
    # RAPEX image URLs are generally of the form XXXs.jpg - the high res version is available at XXXf.jpg
    fullsize_clean_url = clean_url.sub!("s.jpg", "f.jpg")
    file = download_url(fullsize_clean_url)
    file_content_type = file.content_type_parse.first
    file_type = file_content_type.split('/').last
    product.images.attach(io: file, filename: "#{product.name}.#{file_type}", content_type: file_content_type)
  end
end

def create_investigation_product(investigation, product)
  InvestigationProduct.create(
    investigation: investigation,
    product: product
  )
end

def create_activity(notification, investigation, date)
  # TODO: update this to be a CorrectiveActionActivity
  CommentActivity.create(
    investigation: investigation,
    created_at: date,
    updated_at: date,
    description: field_from_notification(notification, "measures"),
    source: ReportSource.new(name: "RAPEX")
  )
end

def barcode_from_notification(notification)
  # There are 4 different types of GTIN, so we match for any of them
  regex = /(
    \d{1}\s?-?\d{6}\s?-?\d{6}|
    \d{1}\s?-?\d{5}\s?-?\d{5}\s?-?\d{1}|
    \d{4}\s?-?\d{4}|
    \d{1}\s?-?\d{2}\s?-?\d{5}\s?-?\d{5}\s?-?\d{1})/x
  batch_barcode = field_from_notification(notification, "batchNumber_barcode")
  barcode = batch_barcode[regex, 1]
  barcode = barcode.tr("-", "").tr(" ", "") unless barcode.nil?
  barcode
end

def name_or_product(notification)
  name = field_from_notification(notification, "name")
  name = nil if name.casecmp("Unknown").zero? || name.empty?
  product = field_from_notification(notification, "product")
  product = nil if product.casecmp("Unknown").zero? || product.empty?
  name || product
end

def brand(notification)
  brand = field_from_notification(notification, "brand")
  brand = nil if brand.casecmp("Unknown").zero?
  brand
end

def risk_level(notification)
  level_map = {
    "Serious risk" => :serious,
    "Other risk level" => :medium
  }
  level_map.default = nil
  level_map[field_from_notification(notification, "level")]
end

def field_from_notification(notification, field_name)
  field = notification.xpath(field_name)[0]
  field = field.text.delete("\n\r") unless field.nil?
  field
end

def notifications(url)
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
