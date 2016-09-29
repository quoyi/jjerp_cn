$(function() {
  // 子订单 --> 导入拆单文件
  $("#import-btn").click(function(e) {
    e.preventDefault();
    $("#import-field-file").click();
    $("#import-field-file").bind("change", function() {
      $("#import-form").submit();
    });
  });

  // ajax 方式获取指定 省市县 的代理商，并修改代理商可选项
  function ajaxGetAgent(condition){
    $.ajax({
      url: "/agents/search",
      type: "get",
      dataType: "json",
      data: condition,
      success: function(data){
        if(data != null){
          var options = "<option value=''>请选择</option>";
          for (var i = 0; i <= data.length - 1; i++) {
            options += "<option value='" + data[i].id + "'>" + data[i].full_name + "</option>"; 
          }
          $(".orders-search-agent").empty().append(options);
        }
      },
      error: function(){

      }
    });
  }

  // 子订单 - 搜索条件 - 省市县 修改后，搜索对应的代理商
  $(".orders-search-province").change(function(){
    var data = {province: $(this).val()};
    ajaxGetAgent(data);
  });
  $(".orders-search-city").change(function(){
    var data = {province: $(this).siblings(".orders-search-province").val(), city: $(this).val()};
    ajaxGetAgent(data);
  });
  $(".orders-search-district").change(function(){
    var data = {province: $(this).siblings(".orders-search-province").val(), city: $(this).siblings(".orders-search-city").val(), district: $(this).val()};
    ajaxGetAgent(data);
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
      jsNoty("网络错误，无法获取子配件类型！", "error");
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
      jsNoty("网络错误，无法获取配件价格！", "error");
    }
  });
}

/**
 * 设置工艺单位、单价
 */
function setCraft(obj){
  var fields = $(obj).parents(".fields");
  $.ajax({
    url: "/craft_categories/find",
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
      jsNoty("网络错误，无法获取配件价格！", "error");
    }
  });
}

/**
 * 修改 子订单 -- 编辑部件 -- 长宽后，设置 尺寸
 * @param {[type]} obj [description]
 */
function setOrderUnitSize(obj){
  var fieldsElement = $(obj).parents(".fields");
  var lengthElement = fieldsElement.find(".order-unit-length");
  var widthElement = fieldsElement.find(".order-unit-width");
  var sizeElement = fieldsElement.find(".order-unit-size");
  sizeElement.val((Number(lengthElement.val()) + 2) + "*" + (Number(widthElement.val()) + 2));
}

/**
 * 修改 子订单 -- 编辑部件 -- 尺寸后，设置 长宽
 * @param {[type]} obj [description]
 */
function setOrderUnitLengthWidth(obj){
  var fieldsElement = $(obj).parents(".fields");
  var lengthElement = fieldsElement.find(".order-unit-length");
  var widthElement = fieldsElement.find(".order-unit-width");
  var sizeElement = $(obj);
  var sizes = sizeElement.val().split("*");
  if(sizes.length > 0 && sizes.length == 2){
    // 长宽未填写时，才需要自动填写（防止将已填写的数据覆盖）
    if(lengthElement.val() == null || lengthElement.val() <= 1){
      var length = sizes[0] - 2;
      if(length > 0){
        lengthElement.val(length);
      }else{
        lengthElement.val(1);
      }
    }
    if(widthElement.val() == null || widthElement.val() <= 1){
      var width = sizes[1] - 2;
      if(width > 0){
        widthElement.val(width);
      }else{
        widthElement.val(1);
      }
    }
  }
}

/**
 * 订单 -- 转款
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function changeIncomeOrder(obj){
  var order_id = $(obj).val();
  var price_field = $(obj).parents(".row").find(".change_income_order_price");
  var price = price_field.val();
  if(order_id != null && order_id != ""){
    $.ajax({
      url: "/orders/" + order_id,
      type: "GET",
      dataType: "JSON",
      success: function(data){
        // console.log(data);
        price_field.val(data.arrear);
        price_field.attr("max", data.arrear);
      },
      error: function(data){
        jsNoty("网络错误，无法获取子订单信息！", "error");
      }
    });
  }
}