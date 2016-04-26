$(function(){
  // 设置 jquery.noty 插件，显示通知信息
    var myNoty = {
        text: '这里是提示信息', // 通知框信息内容
        timeout: 5000, // 设值自动关闭时间（毫秒），false表示不自动关闭
        type: 'success', // 显示方式：success、alert
        theme: 'bootstrapTheme', // 主题样式： relax、defaultTheme、bootstrapTheme
        layout: 'bottomRight', // 通知框位置 top、topLeft、topCenter、topRight、center、bottom等
        // dismissQueue: true,  // 启用消息队列
        // template: '<div class="noty_message"><span class="noty_text"></span><div class="noty_close"></div></div>', // 弹出通知框
        // modal: false, // 是否模态
        // killer: false, // 显示前，先清除所有通知框
        // buttons: false, // 按钮数组 false 或者 [ { addClass: 'btn btn-primary', text: 'Ok', onClick: function($noty){...}}, button2, button3 ]
        closeWith: ['click'], // 关闭方式： ['click', 'button', 'hover', 'backdrop']（递归关闭所有通知框）
        maxVisible: 10, // 最多可见数量
        animation: { // 动画方式
            open: 'animated bounceInUp', // Animate.css 中的class 名称
            close: 'animated bounceOutDown', // Animate.css 中的class 名称
            easing: 'swing', // 非必须。使用 Animate.css 时，此设值无效
            speed: 500 // 非必须。使用 Animate.css 时，此设值无效
        },
        callback: { // 回调函数
            onShow: function() {},
            afterShow: function() {},
            onClose: function() {},
            afterClose: function() {},
            onCloseClick: function() {}
        }
    };
    // 调用已定义的 noty 插件
    // missing options such as Theme!!
    $("#noty_test").click(function(e) {
        console.log(myNoty);
        e.preventDefault();
        noty(myNoty);
    });

});