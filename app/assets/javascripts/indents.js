$(function() {
  /****** 总订单 新建 --- 时间选择逻辑  开始 ******/
  $("[data-provide=datepicker]").datepicker({
    format: 'yyyy-mm-dd',
    language: 'zh-CN',
    autoclose: true
  }).on('changeDate', function(e) {
    var targetId = $(this).attr('id');

    // 发货时间默认值、选定值必须大于当前时间
    if (targetId == 'indent_require_at') {
      // 获取当前时间，并加10天
      var now = new Date();
      var logic = now.setDate(now.getDate() + 10);
      var require_at = e.date;
      if (require_at < logic) {
        jsNoty("建议发货时间为10天后！", "warning");
      }
    }
  });
  /****** 总订单 新建 --- 时间选择逻辑  结束 ******/


  /****** 总订单 新建 --- 代理商 与 物流 的联动逻辑  开始 ******/
  //ajax动态搜索组团社联系人
  $('#indentAjaxSearchAgent').each((function(_this) {
    return function(i, e) {
      var options, select;
      select = $(e);
      options = {
        placeholder: "搜索代理商名称",
        minimumInputLength: 0
      };
      if (select.hasClass('ajax')) {
        options.ajax = {
          url: "/agents.json",
          dataType: 'json',
          data: function(term, page) {
            return {
              term: term,
              page: page,
              per: 25
            };
          },
          results: function(data, page) {
            return {
              results: data.agents,
              more: data.total > (page * 25)
            };
          }
        };
        options.dropdownCssClass = "bigdrop";
      }
      return select.select2(options).select2("data", {
          "id": $("#indentAjaxSearchAgent").data("id"),
          "text": (isNaN($("#indentAjaxSearchAgent").data("name")) ? $("#indentAjaxSearchAgent").data("name") : "搜索代理商名称")
        } //初始化数据
      );;
    };
  })(this)).change(function(){
    var $select2 = $(this);
    $.ajax({
      url: "/agents/" + $select2.val(),
      dataType: 'json',
      type: 'GET',
      success: function(data){
        var $panels = $select2.parents(".panel-heading");
        $panels.find("#indent_logistics").val(data.logistics);
        $panels.find("#indent_delivery_address").val(data.delivery_address);
      },
      error: function(data){
        jsNoty("网络错误！","error");
      }
    });
  });
  /****** 总订单 新建 --- 代理商 与 物流 的联动逻辑  结束 ******/


  /****** 总订单 列表 添加收入 --- 订单价格、收支信息的计算逻辑  开始 ******/
  // 获取所点击表单行，对应的订单ID，并赋值给弹出框中对应的项
  $("#addIncomes").on('show.bs.modal', function(e) {
    if (e != null && e.relatedTarget != null) {
      // 获取 订单号、应收金额、已收金额
      var order_id = e.relatedTarget.dataset.order;
      if (order_id != null && order_id != "") {
        var amount = e.relatedTarget.dataset.amount;
        var arrear = e.relatedTarget.dataset.arrear;
        var username = e.relatedTarget.dataset.username;
        $("#income_order_id").val(order_id);
        $("#income_should").val(amount);
        $("#income_yet").val(amount - arrear);
        $("#income_username").val(username);
      }
    }
  });
  /****** 总订单 列表 添加收入 --- 订单价格、收支信息的计算逻辑  开始 ******/


  $("#addSent").on('show.bs.modal', function(e) {
    if (e != null && e.relatedTarget != null) {
      var indent_id = e.relatedTarget.dataset.indent;
      $("#sent_indent_id").val(indent_id);
    }
  });

  //ajax动态搜索组团社联系人
  // $(".remoteDataAgent").select2({
  //   language: 'zh-CN',
  //   theme: 'bootstrap',
  //   // allowClear: true,
  //   placeholder: "全部",
  //   minimumInputLength: 0,
  //   ajax: {
  //     url: '/agents.json',
  //     dataType: 'json',
  //     delay: 250,
  //     cache: true,
  //     data: function(params){
  //       return {
  //         term: params.term,
  //         page: params.page || 1
  //       };
  //     },
  //     processResults: function(data, params){
  //       params.page = params.page || 1;
  //       return {
  //         results: data.agents,
  //         pagination: {
  //           more: (params.page * 6) < data.total
  //         }
  //       };
  //     }
  //   }
  // });



  $(".remoteDataAgent").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "全部",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/agents.json',
      dataType: 'json',
      delay: 250,
      cache: true,
      data: function(params){
        return {
          term: params.term,
          page: params.page || 1
        };
      },
      processResults: function(data, params){
        params.page = params.page || 1;
        return {
          results: data.agents,
          pagination: {
            more: (params.page * 6) < data.total
          }
        };
      }
    }
  }).on("select2:select", function(e){
    var $select2 = $(this);
    $.ajax({
      url: "/agents/" + $select2.val(),
      dataType: 'json',
      type: 'GET',
      success: function(data){
        var $panels = $select2.parents(".panel-heading");
        $panels.find("#indent_logistics").val(data.logistics);
        $panels.find("#indent_delivery_address").val(data.delivery_address);
      },
      error: function(data){
        jsNoty("网络错误！","error");
      }
    });
  });
});


/****** 总订单 新建 子订单 --- 价格 与 板料厚度、材质、颜色 的联动逻辑  开始 ******/
// $('#indentAjaxSearchMaterial').each((function(_this) {
//     return function(i, e) {
//       var options, select;
//       select = $(e);
//       options = {
//         placeholder: "搜索代理商名称",
//         minimumInputLength: 0
//       };
//       if (select.hasClass('ajax')) {
//         options.ajax = {
//           url: "/material_categories.json",
//           dataType: 'json',
//           data: function(term, page) {
//             return {
//               term: term,
//               page: page,
//               per: 25
//             };
//           },
//           results: function(data, page) {
//             return {
//               results: data.agents,
//               more: data.total > (page * 25)
//             };
//           }
//         };
//         options.dropdownCssClass = "bigdrop";
//       }
//       return select.select2(options).select2("data", {
//           "id": $("#indentAjaxSearchMaterial").data("id"),
//           "text": (isNaN($("#indentAjaxSearchMaterial").data("name")) ? $("#indentAjaxSearchMaterial").data("name") : "搜索代理商名称")
//         } //初始化数据
//       );;
//     };
//   })(this));//.change(function(){
  //   var $select2 = $(this);
  //   $.ajax({
  //     url: "/agents/" + $select2.val(),
  //     dataType: 'json',
  //     type: 'GET',
  //     success: function(data){
  //       var $panels = $select2.parents(".panel-heading");
  //       $panels.find("#indent_logistics").val(data.logistics);
  //       $panels.find("#indent_delivery_address").val(data.delivery_address);
  //     },
  //     error: function(data){
  //       jsNoty("网络错误！","error");
  //     }
  //   });
  // });
/**
 * Ajax 获取指定 板料价格
 */
function getMaterialPrice(obj) {
  var fields = $(obj).parents(".fields");
  var ply = fields.find(".material-ply").val();
  var texture = fields.find(".material-texture").val();
  var color = fields.find(".material-color").val();
  //alert("ply: " + ply + " texture: " + texture + " color: " + color);
  $.ajax({
    url: "/materials/find/",
    dataType: 'json',
    data: {
      ply: ply,
      texture: texture,
      color: color
    },
    type: 'POST',
    success: function(data) {
      if (data != null) {
        console.log(data);
        fields.find(".material-uom").val(data.uom);
        fields.find(".material-price").val(data.price);
      } else {
        fields.find(".material-price").val(0);
      }
    },
    error: function(data) {
      jsNoty("网络错误！", "error");
    }
  });
}


//全选和反选(未发货not_sent.html)
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


function sent_list() {
  var ids = new Array();
  var sents_ids = $("#sents_ids");
  var check_boxes = $('.index_checkbox');
  for (var i = 0; i < $('.index_checkbox').length; i++) {
    if (check_boxes[i].checked) {
      ids.push(check_boxes[i].value);
    }
  }
  if (ids.length == 0) {
    jsNoty("请先选中所要下载的发货信息！", "warning");
    return false;
  }
  sents_ids.val(ids);

  // url = "/sent_lists";
  // $("#batch_set").attr('action', url);
}



/****** 总订单 新建 子订单 --- 价格 与 板料厚度、材质、颜色 的联动逻辑  结束 ******/