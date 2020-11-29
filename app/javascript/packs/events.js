global.$ = window.$ = window.jQuery = $;

document.addEventListener('turbolinks:load', () => {
  window.dispatchEvent(new Event("resize")); // 重设页面大小
});