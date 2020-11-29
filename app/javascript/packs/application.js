import '../stylesheets/application';

global.$ = window.$ = window.jQuery = $;

import "trix"
import "@rails/actiontext"
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import "bootstrap/dist/js/bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import "sticky-kit/dist/sticky-kit";
import "owl.carousel/dist/owl.carousel";
import "./theme";
import "./events";

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
require.context('../images', true)
