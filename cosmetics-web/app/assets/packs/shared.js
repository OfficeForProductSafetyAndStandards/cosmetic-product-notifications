// JS
import Rails from 'rails-ujs';
import GOVUKFrontend from 'govuk-frontend';
import Dropzone from 'dropzone';

import '../application/javascripts/bulk_file_upload_error_handling';
import '../application/javascripts/dropzone_config';

import 'shared-web/app/assets/application/javascripts/location_picker';

// Styles
import 'govuk-country-and-territory-autocomplete/dist/location-autocomplete.min.css';

// Images
import 'govuk-frontend/assets/images/favicon.ico';
import 'govuk-frontend/assets/images/govuk-mask-icon.svg';
import 'govuk-frontend/assets/images/govuk-crest-2x.png';
import 'govuk-frontend/assets/images/govuk-apple-touch-icon-180x180.png';
import 'govuk-frontend/assets/images/govuk-apple-touch-icon-167x167.png';
import 'govuk-frontend/assets/images/govuk-apple-touch-icon-152x152.png';
import 'govuk-frontend/assets/images/govuk-apple-touch-icon.png';
import 'govuk-frontend/assets/images/govuk-opengraph-image.png';
import 'govuk-frontend/assets/images/govuk-logotype-crown.png';

Rails.start();
window.GOVUKFrontend = GOVUKFrontend;
