// JS
import Rails from 'rails-ujs'
import GOVUKFrontend from 'govuk-frontend'

import '../application/javascripts/location_picker'
import '../application/javascripts/autocomplete'
import '../application/javascripts/bulk_file_upload_error_handling'

// Styles
import 'accessible-autocomplete/src/autocomplete.css'
// Images
import 'govuk-frontend/govuk/assets/images/favicon.ico'
import 'govuk-frontend/govuk/assets/images/govuk-mask-icon.svg'
import 'govuk-frontend/govuk/assets/images/govuk-crest-2x.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-180x180.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-167x167.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-152x152.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon.png'
import 'govuk-frontend/govuk/assets/images/govuk-opengraph-image.png'
import 'govuk-frontend/govuk/assets/images/govuk-logotype-crown.png'

Rails.start()
window.GOVUKFrontend = GOVUKFrontend
