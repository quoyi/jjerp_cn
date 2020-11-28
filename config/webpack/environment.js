const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    _: 'lodash',
    $: 'jquery',
    jQuery: 'jquery',
    is: 'is_js/is',
    'window._': 'lodash',
    'window.$': 'jquery',
    'window.jQuery': 'jquery',
    'window.is': 'is_js/is',
    Popper: ['popper.js', 'default'],
    ActionCable: '@rails/actioncable',
    Stickyfill: 'stickyfilljs',
    PerfectScrollbar: 'perfect-scrollbar'
  })
);

environment.splitChunks();

// 解决第三方库样式文件相对路径问题
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

module.exports = environment
