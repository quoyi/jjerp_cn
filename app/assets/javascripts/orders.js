$(function() {
  // 子订单 --> 导入拆单文件
  $("#import-btn").click(function(e) {
    e.preventDefault();
    $("#import-field-file").click();
    $("#import-field-file").bind("change", function() {
      $("#import-form").submit();
    });
  });
});

/**
function checkMaterial(selector) {
  var ply = $(selector).parents(".fields").find(".order-custom-offer-ply").val();
  var texture = $(selector).parents(".fields").find(".order-custom-offer-texture").val();
  var color = $(selector).parents(".fields").find(".order-custom-offer-color").val();
  // console.log("ply: " + ply + " texture: " + texture + " color: " + color);
  $.ajax({
    url: "/materials",
    type: "GET",
    data: {
      ply: ply,
      texture: texture,
      color: color
    },
    dataType: 'json',
    success: function(data) {
      if (data.flag == "false") {
        alert("板料未定义！");
        // 恢复默认选中第一项
        $("#" + selector.id + " option:first").prop("selected", "selected");
      }
    }
  });
}
**/
