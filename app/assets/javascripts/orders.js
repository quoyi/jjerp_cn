$(function() {
  // 子订单 --> 导入拆单文件
  $("#import-btn").click(function(e) {
    e.preventDefault();
    $("#import-field-file").click();
    $("#import-field-file").bind("change", function() {
      $("#import-form").submit();
    });
  });

  $(".basic-part-category").change(function(){
    alert(123);
  });
});


/**
 * 设置子类型可选项
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function setChildPartCategory(obj){
  var fields = $(obj).parents(".fields");
  var child = fields.find(".child-part-category");
  var uom = fields.find(".part-category-uom");
  var price = fields.find(".part-category-price");
  var supply = fields.find(".part-category-supply");
  $.ajax({
    url: "/part_categories/find",
    dataType: "json",
    data: {parent_id: $(obj).val()},
    type: "POST",
    success: function(data){
      var options = "";
      for (var i = 0; i <= data.length - 1; i++) {
        if(i == 0){
          uom.val(data[i].uom);
          price.val(data[i].price);
          supply.val(data[i].supply_id);
        }
        options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>"; 
      }
      child.empty().append(options);
    },
    error: function(data){
      alert("网络错误，无法获取子配件类型！");
    }
  });
}
/**
 * 设置父类型选中
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function setPartCategoryPrice(obj){
  var fields = $(obj).parents(".fields");
  var uom = fields.find(".part-category-uom");
  var price = fields.find(".part-category-price");
  var supply = fields.find(".part-category-supply");
  $.ajax({
    url: "/part_categories/find",
    dataType: "json",
    data: {id: $(obj).val()},
    type: "POST",
    success: function(data){
      if(data != null){
        uom.val(data[0].uom);
        price.val(data[0].price);
        supply.val(data[0].supply_id);
      }
    },
    error: function(data){
      alert("网络错误，无法获取配件价格！");
    }
  });
}