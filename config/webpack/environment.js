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

// environment.splitChunks();

// 解决第三方库样式文件相对路径问题
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

module.exports = environment
