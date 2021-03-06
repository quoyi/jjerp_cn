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
      cache: false,
      success: function(data){
        // console.log(data);
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

  // 子订单 - 自定义报价 - 板料 select2
  $(".material-ply").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "板厚",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/material_categories.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'ply',
          term: params.term,
          page: params.page || 1
        };
      },
      processResults: function(data, params){
        params.page = params.page || 1;
        return {
          results: data.material_categories,
          pagination: {
            more: (params.page * 6) < data.total
          }
        };
      }
    }
  });
  $(".material-texture").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "材质",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/material_categories.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'texture',
          term: params.term,
          page: params.page || 1
        };
      },
      processResults: function(data, params){
        params.page = params.page || 1;
        return {
          results: data.material_categories,
          pagination: {
            more: (params.page * 6) < data.total
          }
        };
      }
    }
  });
  $(".material-color").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "颜色",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/material_categories.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'color',
          term: params.term,
          page: params.page || 1
        };
      },
      processResults: function(data, params){
        params.page = params.page || 1;
        return {
          results: data.material_categories,
          pagination: {
            more: (params.page * 6) < data.total
          }
        };
      }
    }
  });
  $("#custom-offer-fields").on("nested:fieldAdded", function(e){
    var fields = e.field;
    // var custom_offer_full_name = fields.find(".custom-offer-full-name").attr("name");
    var ply_field = fields.find(".material-ply");
    var texture_field = fields.find(".material-texture");
    var color_field = fields.find(".material-color");
    // ply_field.attr("name", custom_offer_full_name.replace("full_name", "ply"));
    // texture_field.attr("name", custom_offer_full_name.replace("full_name", "texture"));
    // color_field.attr("name", custom_offer_full_name.replace("full_name", "color"));
    // 子订单 - 自定义报价 - 板料 select2
    ply_field.select2({
      language: 'zh-CN',
      theme: 'bootstrap',
      placeholder: "板厚",
      minimumInputLength: 0,
      allowClear: true,
      ajax: {
        url: '/material_categories.json',
        dataType: 'json',
        delay: 250,
        cache: false,
        data: function(params){
          return {
            oftype: 'ply',
            term: params.term,
            page: params.page || 1
          };
        },
        processResults: function(data, params){
          params.page = params.page || 1;
          return {
            results: data.material_categories,
            pagination: {
              more: (params.page * 6) < data.total
            }
          };
        }
      }
    });
    texture_field.select2({
      language: 'zh-CN',
      theme: 'bootstrap',
      placeholder: "材质",
      minimumInputLength: 0,
      allowClear: true,
      ajax: {
        url: '/material_categories.json',
        dataType: 'json',
        delay: 250,
        cache: false,
        data: function(params){
          return {
            oftype: 'texture',
            term: params.term,
            page: params.page || 1
          };
        },
        processResults: function(data, params){
          params.page = params.page || 1;
          return {
            results: data.material_categories,
            pagination: {
              more: (params.page * 6) < data.total
            }
          };
        }
      }
    });
    color_field.select2({
      language: 'zh-CN',
      theme: 'bootstrap',
      placeholder: "颜色",
      minimumInputLength: 0,
      allowClear: true,
      ajax: {
        url: '/material_categories.json',
        dataType: 'json',
        delay: 250,
        cache: false,
        data: function(params){
          return {
            oftype: 'color',
            term: params.term,
            page: params.page || 1
          };
        },
        processResults: function(data, params){
          params.page = params.page || 1;
          return {
            results: data.material_categories,
            pagination: {
              more: (params.page * 6) < data.total
            }
          };
        }
      }
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
    cache: false,
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
      jsNoty("error", "网络错误，无法获取子配件类型！");
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
    cache: false,
    success: function(data){
      if(data != null){
        fields.find(".part-category-uom").val(data[0].uom);
        fields.find(".part-category-price").val(data[0].price);
        fields.find(".part-category-supply").val(data[0].supply_id);
      }
    },
    error: function(data){
      jsNoty("error", "网络错误，无法获取配件价格！");
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
    cache: false,
    success: function(data){
      if(data != null){
        fields.find(".order_craft_uom").val(data.uom);
        fields.find(".order_craft_price").val(data.price);
      }
    },
    error: function(data){
      jsNoty("error", "网络错误，无法获取配件价格！");
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
  // 所转款项 必须验证是否超过 收入/订单总金额
  // var order_id = $(obj).val();
  // var price_field = $(obj).parents(".row").find(".change_income_order_price");
  // if(order_id != null && order_id != ""){
  //   $.ajax({
  //     url: "/orders/" + order_id,
  //     type: "GET",
  //     dataType: "JSON",
  //     cache: false,
  //     success: function(data){
  //       // console.log(data);
  //       price_field.val(data.arrear);
  //       price_field.attr("max", data.arrear);
  //     },
  //     error: function(data){
  //       jsNoty("error", "网络错误，无法获取子订单信息！");
  //     }
  //   });
  // }
}

// 子订单 - 待发货 全选和反选(未发货not_sent.html)
function CheckSelect(id) {
  var check_boxes = $('.checkbox-' + id);
  for (var i = 0; i < check_boxes.length; i++) {
    // 提取控件  
    var checkbox = check_boxes[i];
    // 检查是否是指定的控件  
    if (checkbox.checked === false) {
      // 正选  
      checkbox.checked = true;
    } else if (checkbox.checked === true) {
      // 反选  
      checkbox.checked = false;
    }
  }
}

// 子订单 - 待发货 提交发货清单
function sent_list() {
  var ids = new Array();
  var $check_boxes = $('.index_checkbox');
  for (var i = 0; i < $check_boxes.length; i++) {
    if ($check_boxes[i].checked) {
      ids.push($check_boxes[i].value);
    }
  }
  if (ids.length == 0) {
    jsNoty("warning", "请先选中所要下载的发货信息！");
    return false;
  }
  $("#sents_ids").val(ids);

  // url = "/sent_lists";
  // $("#batch_set").attr('action', url);
}