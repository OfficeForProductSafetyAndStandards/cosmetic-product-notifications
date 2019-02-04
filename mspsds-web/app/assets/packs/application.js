// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/assets and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// JS
import Rails from 'rails-ujs';
import GOVUKFrontend from 'govuk-frontend';

import '../application/javascripts/investigations/attachment_description';
import '../application/javascripts/investigations/corrective_actions';
import '../application/javascripts/investigations/legislation_picker';
import '../application/javascripts/autocomplete';
import '../application/javascripts/creation_flow';
import '../application/javascripts/investigations';
import '../application/javascripts/location_picker';

// Styles
import 'govuk-country-and-territory-autocomplete/dist/location-autocomplete.min.css';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';

import '../application/stylesheets/main.scss';

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

import '../application/images/document_placeholder.png';

Rails.start();
window.GOVUKFrontend = GOVUKFrontend;
