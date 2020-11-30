// document.addEventListener('turbolinks:load', () => {
//   window.dispatchEvent(new Event("resize")); // 重设页面大小

//   $('body').scrollspy({ target: '#static-scroll' });

//   $('.toast').toast({ delay: 2000 }).toast('show');
// });

$(function() {
  window.dispatchEvent(new Event("resize")); // 重设页面大小

  $('body').scrollspy({ target: '#static-scroll' });

  $('.toast').toast({ delay: 2000 }).toast('show');
});
