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
        jsNoty("warning", "建议发货时间为10天后！");
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
          cache: false,
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
      cache: false,
      success: function(data){
        var $panels = $select2.parents(".panel-heading");
        $panels.find("#indent_logistics").val(data.logistics);
        $panels.find("#indent_delivery_address").val(data.delivery_address);
      },
      error: function(data){
        jsNoty("error", "网络错误！");
      }
    });
  });
  /****** 总订单 新建 --- 代理商 与 物流 的联动逻辑  结束 ******/


  /****** 总订单 列表 添加收入 --- 订单价格、收支信息的计算逻辑  开始 ******/
  // 获取所点击表单行，对应的订单ID，并赋值给弹出框中对应的项
  $("#addIncomes").on('show.bs.modal', function(e) {
    if (e != null && e.relatedTarget != null) {
      // 获取 订单号、应收金额、已收金额
      var order_string = e.relatedTarget.dataset.order;
      if (order_string != null && order_string != "") {
        var order = JSON.parse(order_string);
        var username = e.relatedTarget.dataset.username;
        var $order_field = $(e.currentTarget).find("#income_new_order_id");
        $order_field.empty().append("<input type='text'  value='" + order.name + "' class='form-control' disabled='disabled'/>")
        .append("<input type='hidden' name='income[order_id]' value='" + order.id + "'/>");
        $("#income_should").val(order.price);
        $("#income_yet").val(order.price - order.arrear);
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

  // 物流发货 - 发货/确认页面 使用
  $(".remoteDataAgent").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "店名/代理商名称",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/agents.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'full_name',
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
  });

});

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
    cache: false,
    success: function(data) {
      if (data != null) {
        // console.log(data);
        fields.find(".material-uom").val(data.uom);
        fields.find(".material-price").val(data.price);
      } else {
        fields.find(".material-price").val(0);
      }
    },
    error: function(data) {
      jsNoty("error", "网络错误！");
    }
  });
}
