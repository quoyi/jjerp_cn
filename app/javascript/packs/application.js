// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import '../stylesheets/application.scss';

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// window.$ = window.jQuery = $;
// window._ = _;
// window.is = is;

import "bootstrap";
import "@fortawesome/fontawesome-free";
import "sticky-kit/dist/sticky-kit";
import "./theme";

// Uncomment to copy all static images under ../img to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
const images = require.context('../img', true)
const imagePath = (name) => images(name, true)
