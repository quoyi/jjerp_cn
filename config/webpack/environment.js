const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    _: 'lodash',
    jQuery: 'jquery',
    jquery: 'jquery',
    Popper: ['popper.js', 'default'],
    ActionCable: '@rails/actioncable',
    is: 'is_js/is',
    Stickyfill: 'stickyfilljs',
    PerfectScrollbar: 'perfect-scrollbar'
  })
);

module.exports = environment
