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
    'global.$': 'jquery',
    'window.is': 'is_js/is',
    Popper: ['popper.js', 'default'],
    ActionCable: '@rails/actioncable',
    Stickyfill: 'stickyfilljs',
    'window.Stickyfill': 'stickyfilljs',
    PerfectScrollbar: 'perfect-scrollbar',
    'window.PerfectScrollbar': 'perfect-scrollbar',
    Typed: 'typed.js',
    'window.Typed': 'typed.js',
    Chart: 'chart.js',
    'window.Chart': 'chart.js'
  })
);

environment.splitChunks();

// 解决第三方库样式文件相对路径问题
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

module.exports = environment
