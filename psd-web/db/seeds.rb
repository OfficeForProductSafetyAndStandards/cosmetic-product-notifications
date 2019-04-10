# This solves the issue described by https://github.com/rails/rails/issues/35812
ActiveJob::Base.queue_adapter = Rails.application.config.active_job.queue_adapter

def create_blob(filename, title: nil, description: nil)
  ActiveStorage::Blob.create_after_upload!(io: File.open("./db/seed_files/#{filename}"), filename: filename, content_type: "image/jpeg", metadata: {
    title: title || filename,
    description: description,
    updated: Time.now.iso8601
  })
end

# First investigation
investigation = Investigation::Allegation.new(
  description: "The plastic material of the doll contains bis(2-ethylhexyl) phthalate (DEHP)(measured value: 25.7% by weight). This phthalate may harm the health of children, causing possible damage to their reproductive system. The product does not comply with the REACH Regulation.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Chemical exposure",
  product_category: "Toys",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "John Smith",
  phone_number: "01234567890",
  email_address: "email@email.com",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.save!

product = Product.create!(
  batch_number: "",
  country_of_origin: "country:CN",
  date_placed_on_market: nil,
  description: "Plastic doll (5 different models) with long blonde hair.",
  product_code: "NO.DY807",
  name: "Pretty",
  category: "Toys",
  product_type: "Plastic doll",
  webpage: ""
)

product.documents.attach(create_blob("2019-w6_27505-1f.jpg", title: "Photo of Pretty dolls", description: "4 designs of doll, blonde hair, different coloured dresses."))

investigation.products << product

# Second investigation
investigation = Investigation::Allegation.new(
  description: "The putty contains a magnet which is a small part and has a high magnetic flux.\nIf a child swallows the small magnet and other metallic objects, they could attract one another causing intestinal blockage or perforation.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Other hazard type",
  product_category: "Toys",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Jacob Bonwitt",
  phone_number: "07555555555",
  email_address: "jacob.bonwitt@digital.cabinet-office.gov.uk",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.documents.attach(create_blob("putty 2.jpg"))

investigation.save!

blob = create_blob("putty.jpg", title: "Crazy Geezer's putty world", description: "Top")
investigation.documents.attach(blob)
AuditActivity::Document::Add.from(blob, investigation)

blob = create_blob("putty 3.jpg", title: "Crazy Geezer's putty world", description: "Bottom")
investigation.documents.attach(blob)
AuditActivity::Document::Add.from(blob, investigation)

product = Product.create!(
  batch_number: "Unknown",
  country_of_origin: "country:CN",
  date_placed_on_market: nil,
  description: "Purple magnetic putty with small plastic accessories (eyes and a nose).",
  product_code: "Unknown",
  name: "Crazy Geezer's Putty World",
  category: "Toys",
  product_type: "Putty",
  webpage: "www.amazon.com"
)

investigation.products << product

# Third investigation
investigation = Investigation::Allegation.new(
  description: "The top cap of the fork may not be adequately torqued and could work itself free while the bicycle is being ridden.\n\nThis could cause the air cartridge to spring out of the tube and cause injuries.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Penetrating force",
  product_category: "Other Product Type",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
  )

investigation.complainant = Complainant.new(
  name: "Jacob Bonwitt",
  phone_number: "07555555555",
  email_address: "jacob.bonwitt@digital.cabinet-office.gov.uk",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
  )

investigation.save!

product = Product.create!(
  batch_number: "Unknown",
  country_of_origin: "territory:TW",
  date_placed_on_market: nil,
  description: "",
  product_code: "Unknown",
  name: "RXF 36 and RXF 34 Air Mountain Bike Front Forks",
  category: "Other Product Type",
  product_type: "Bike Suspension Fork",
  webpage: "https://www.mbr.co.uk/news/product-recall-ohlins-rxf-36-rxf-34-379791"
)

product.documents.attach(create_blob("bike fork 1.jpg", title: "Suspension forks"))

product.documents.attach(create_blob("bike fork 2.jpg", title: "Fork close up"))

investigation.products << product

# Fourth investigation
investigation = Investigation::Allegation.new(
  description: "The product contains acetaldehyde and/or propionaldehyde which are skin irritants and are also carcinogenic or an eye irritant respectively.\nIn case of eye contact, ingestion or inhalation, it could lead to eye or lung irritation.",
    is_closed: false,
    user_title: nil,
    hazard_type: "Chemical exposure",
    product_category: "Other Product Type",
    is_private: false,
    hazard_description: nil,
    non_compliant_reason: nil,
    complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Richard Rabbit",
  phone_number: "07856234112",
  email_address: "random@random.com",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
  )

investigation.save!

product = Product.create!(
  batch_number: "Batch 105R sold between February and May 2018",
  country_of_origin: "territory:TW",
  date_placed_on_market: nil,
  description: "",
  product_code: "749266006615",
  name: "Fogbuster Lens Cleaner",
  category: "Other Product Type",
  product_type: "Swim goggles lens cleaner",
  webpage: "https://www.zoggs.com/blog/product-recall-zoggs-fogbuster-and-lens-cleaner/"
)

product.documents.attach(create_blob("demister.jpg", title: "Fogbusters"))

investigation.products << product

# Fifth investigation
investigation = Investigation::Allegation.new(
  description: "Due to its shape, the candle is not sufficiently stable and falls over too easily. As a consequence, it could ignite flammable material and cause a fire.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Fire/burn",
  product_category: "Other Product Type",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Francis O'Connor",
  phone_number: "01234567890",
  email_address: "tradingstandards@email.com",
  complainant_type: "Local authority (Trading Standards)",
  other_details: "Birmingham Offices"
)

investigation.documents.attach(create_blob("2019-w6_27550-1f.jpg"))

investigation.save!

product = Product.create!(
  batch_number: "",
  country_of_origin: "",
  date_placed_on_market: nil,
  description: "White Christmas tree shaped candle, 4 inches high, unstable base.",
  product_code: "8719202753615",
  name: "H&S Collection: Let it snow",
  category: "Other Product Type",
  product_type: "Tree shaped candle",
  webpage: "https://www2.hm.com/en_gb/index.html"
)

product.documents.attach(create_blob("2019-w6_27550-2f.jpg", title: "Photo of tree candle", description: "White Christmas-tree shaped candle with gold logo reading 'Let it snow', in plastic wrapping with white ribbon."))

investigation.products << product

# Sixth investigation
investigation = Investigation::Allegation.new(
  description: "The triangle has a rubber loop attached so that it can be held up. This loop can easily come off the triangle, generating a small part.\r\n\r\nA small child may put the loop in the mouth and choke. \r\n\r\nThe product does not comply with the requirements of the Toy Safety Directive and the relevant European standard EN 71-1.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Asphyxiation",
  product_category: "Toys",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Jacob Bonwitt",
  phone_number: "07555555555",
  email_address: "jacob.bonwitt@digital.cabinet-office.gov.uk",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.save!

product = Product.create!(
  batch_number: "",
  country_of_origin: "country:CN",
  date_placed_on_market: nil,
  description: "",
  product_code: "",
  name: "Funny Musical Instrument Set",
  category: "Toys",
  product_type: "Musical toy",
  webpage: ""
)

product.documents.attach(create_blob("2018-w48_26634-1f.jpg", title: "Triangle"))
product.documents.attach(create_blob("2018-w48_26634-2f.jpg", title: "Xylophone"))

investigation.products << product

business = Business.new(
  trading_name: "ABC toys",
  company_number: "123456",
  legal_name: "ABC limited"
)

business.locations << Location.new(
  name: "Registered office address",
  country: "",
  address_line_1: "1 anytown",
  county: "",
  postal_code: "",
  phone_number: nil,
  address_line_2: "anywhere",
  city: nil
)

business.contacts << Contact.new(
  name: "Mr Smith",
  email: "",
  phone_number: "",
  job_title: ""
)

investigation.investigation_businesses.create!(business: business, relationship: "Manufacturer")

# Seventh investigation
investigation = Investigation::Allegation.new(
  description: "The charging cable of the speaker could overheat.\nThe overheated cable could cause burns if touched or lead to a fire if left close to flammable products.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Fire/burn",
  product_category: "Other Product Type",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Jacob Bonwitt",
  phone_number: "+755555555",
  email_address: "tradingstandards@ts.msa",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.save!

product = Product.create!(
  batch_number: "8710447348123 (LynxThe Golden Year); 8710522349168 (Lynx Black)",
  country_of_origin: "country:CN",
  date_placed_on_market: nil,
  description: "",
  product_code: "Models: Black and The Golden Year; 15800 E11115/ 1804",
  name: "Lynx Shower speaker with USB charger",
  category: "Low Voltage Equipment (inc. plugs & sockets)",
  product_type: "Shower speaker with USB charger",
  webpage: ""
)

product.documents.attach(create_blob("2019-w6_27526-1f.jpg", title: "Lynx packaging"))
product.documents.attach(create_blob("2019-w6_27526-2f.jpg", title: "Lynx packaging"))
product.documents.attach(create_blob("2019-w6_27526-3f.jpg", title: "Lynx instructions"))
product.documents.attach(create_blob("2019-w6_27526-4f.jpg", title: "images of product"))

investigation.products << product

# Eighth investigation
investigation = Investigation::Allegation.new(
  description: "The distance between the primary and secondary windings of the transformer is too small.\nAs a consequence, the cables may overheat and catch fire.\n\nThe product does not comply with the requirements of the Low Voltage Directive and the relevant European Standard EN 60335.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Fire/burn",
  product_category: "Small Electronics",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "Iain McStandards",
  phone_number: "+7563434322",
  email_address: "tradingstandards@ts.msa",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.save!

product = Product.create!(
  batch_number: "X00076P3WF",
  country_of_origin: "country:CN",
  date_placed_on_market: nil,
  description: "",
  product_code: "PN 2124531316474, TJ-65-195334",
  name: "Batterytec Battery charger",
  category: "Small Electronics",
  product_type: "Replacement AC/DC adaptor",
  webpage: ""
)

product.documents.attach(create_blob("2019-w3_27167-3f.jpg", title: "packaging and product"))
product.documents.attach(create_blob("2019-w3_27167-1f.jpg", title: "label"))
product.documents.attach(create_blob("2019-w3_27167-2f.jpg", title: "stickers and serial"))

investigation.products << product

Test::Result.new(
  legislation: "Electrical Equipment (Safety) Regulations 2016",
    result: "other",
    details: "Passed tests 1 to 4 and failed test 5",
    date: "2018-03-31",
    investigation: investigation,
    product: product
)

# Ninth investigation
investigation = Investigation::Allegation.new(
  description: "The clothing set contains cords with embellishments at the end in the neck area.\nThe cords can become trapped during various activities of the child, leading to strangulation and the embellishment can be put in the mouth, leading to choking.",
  is_closed: false,
  user_title: nil,
  hazard_type: "Asphyxiation",
  product_category: "Baby/Children's Products",
  is_private: false,
  hazard_description: nil,
  non_compliant_reason: nil,
  complainant_reference: nil
)

investigation.complainant = Complainant.new(
  name: "John O'Standards",
  phone_number: "02092344431",
  email_address: "tradingstandards@ts.msa",
  complainant_type: "Local authority (Trading Standards)",
  other_details: ""
)

investigation.save!

product = Product.create!(
  batch_number: "3105 & 1109",
  country_of_origin: "country:ES",
  date_placed_on_market: nil,
  description: "",
  product_code: "",
  name: "Creaciones Gavidia Babies' clothing set",
  category: "Clothing (inc. baby)",
  product_type: "Babies' clothing set",
  webpage: ""
)

product.documents.attach(create_blob("2019-w2_27234-1f.jpg", title: "babygro"))

investigation.products << product
