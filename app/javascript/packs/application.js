import '../stylesheets/application';

// 已通过 `config/webpack/environment.js` 配置
// global.$ = window.$ = window.jQuery = $;
// window.Stickyfill = Stickyfill;
// window.PerfectScrollbar = PerfectScrollbar;
// window.Typed = Typed;
// window.Chart = Chart;

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
// import "stickyfilljs/dist/stickyfill";
import "sticky-kit/dist/sticky-kit";
// import "is_js/is";
// import "lodash/lodash";
// import "perfect-scrollbar/dist/perfect-scrollbar";
// import "chart.js/dist/Chart";
import "datatables/media/js/jquery.dataTables";
import "datatables.net-bs4/js/dataTables.bootstrap4";
import "datatables.net-responsive/js/dataTables.responsive";
import "datatables.net-responsive-bs4/js/responsive.bootstrap4";
import "leaflet/dist/leaflet";
import "leaflet.markercluster/dist/leaflet.markercluster";
import "leaflet.tilelayer.colorfilter/src/leaflet-tilelayer-colorfilter";

import "owl.carousel/dist/owl.carousel"; // 目前仅静态页面使用

import "./theme";
import "./events";

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
require.context('../images', true)
