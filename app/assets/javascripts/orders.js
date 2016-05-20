$(function() {
  // 子订单 --> 导入拆单文件
  $("#import-btn").click(function(e) {
    e.preventDefault();
    $("#import-field-file").click();
    $("#import-field-file").bind("change",function(){
      $("#import-form").submit();
    });
  });

  // 订单 --> 添加子订单(新增一行)
  $("#add-new-order").click(function(){
    alert($("#order-fields").html());
  });
  // 订单 --> 添加子订单（删除一行）
  $("#remove-last-order").click(function(){
    alert(321);
  });
});