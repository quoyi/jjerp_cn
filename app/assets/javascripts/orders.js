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
 * 设置子类型可选项
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function setChildPartCategory(obj){
  var fields = $(obj).parents(".fields");
  $.ajax({
    url: "/part_categories/find",
    dataType: "json",
    data: {parent_id: $(obj).val()},
    type: "POST",
    success: function(data){
      if(data != null){
        var options = "";
        for (var i = 0; i <= data.length - 1; i++) {
          if(i == 0){
            fields.find(".part-category-uom").val(data[i].uom);
            fields.find(".part-category-price").val(data[i].price);
            fields.find(".part-category-supply").val(data[i].supply_id);
          }
          options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>"; 
        }
        fields.find(".child-part-category").empty().append(options);
      }
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
  $.ajax({
    url: "/part_categories/find",
    dataType: "json",
    data: {id: $(obj).val()},
    type: "POST",
    success: function(data){
      if(data != null){
        fields.find(".part-category-uom").val(data[0].uom);
        fields.find(".part-category-price").val(data[0].price);
        fields.find(".part-category-supply").val(data[0].supply_id);
      }
    },
    error: function(data){
      alert("网络错误，无法获取配件价格！");
    }
  });
}

/**
 * 设置工艺单位、单价
 */
function setCraft(obj){
  var fields = $(obj).parents(".fields");
  $.ajax({
    url: "/crafts/find",
    dataType: "json",
    data: {id: $(obj).val()},
    type: "POST",
    success: function(data){
      if(data != null){
        fields.find(".order_craft_uom").val(data.uom);
        fields.find(".order_craft_price").val(data.price);
      }
    },
    error: function(data){
      alert("网络错误，无法获取配件价格！");
    }
  });
}


function setOrderUnitSize(obj){
  var fields = $(obj).parents(".fields");
  var length = fields.find(".order-unit-length").val();
  var width = fields.find(".order-unit-width").val();
  fields.find(".order-unit-size").val((Number(length) + 2) + "*" + (Number(width) + 2));
}