$(document).ready(function() {
  // 左边菜单效果
  $(".submenu > a").click(function(e) {
    e.preventDefault();
    var $li = $(this).parent("li");
    var $ul = $(this).next("ul");

    if ($li.hasClass("open")) {
      $ul.slideUp(350);
      $li.removeClass("open");
    } else {
      $(".nav > li > ul").slideUp(350);
      $(".nav > li").removeClass("open");
      $ul.slideDown(350);
      $li.addClass("open");
    }
  });

});

/**
 * 显示脚本通知
 * @param  {[type]} msg  通知信息
 * @param  {[type]} type 通知类型： success.成功   error.错误
 */
function jsNoty(msg, type){
  noty({
    text: msg,
    type: type,
    theme: 'bootstrapTheme',
    layout: 'bottomRight',
    // timeout: 8000,
    closeWith: ['button', 'click'],
    template: '<div class="alert alert-'+ type +'"><span class="noty_text"></span><div class="noty_close"></div></div>',
    animation: { // 动画方式
      open: 'animated bounceInDown', // Animate.css 中的class 名称
      close: 'animated bounceOutDown', // Animate.css 中的class 名称
      easing: 'swing', // 非必须。使用 Animate.css 时，此设值无效
      speed: 500 // 非必须。使用 Animate.css 时，此设值无效
    }
  });
}