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
        alert("建议发货时间为10天后！");
      }
    }
  });
  /****** 总订单 新建 --- 时间选择逻辑  结束 ******/


  /****** 总订单 新建 --- 代理商 与 物流 的联动逻辑  开始 ******/
  /**
   * Ajax 获取指定 agent_id 的 agent 对象，并设置indent.logistics
   */
  function getAgentLogistics(agent_id){
    $.ajax({
      url: "/agents/" + agent_id,
      dataType: 'json',
      type: 'GET',
      success: function(data){
        $("#indent_logistics").val(data.logistics);
        $("#agent_address").text(data.province+data.city+data.district+data.town+data.address)
      },
      error: function(data){
        alert("Error");
      }
    });
  }

  /**
   * 模态框显示时，初始化物流输入框
   */
  $("#addIndent").on('shown.bs.modal', function(){
    var agent_id = $("#indent_agent_id").val();
    getAgentLogistics(agent_id);
  });

  /**
   * 监听选择代理商事件，级联改变indent.logistics值
   */
  $("#indent_agent_id").change(function(){
    var agent_id = $(this).val();
    getAgentLogistics(agent_id);
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
  return $('#remoteDataAgent').each((function(_this) {
    return function(i, e) {
      var options, select;
      select = $(e);
      options = {
        placeholder: "代理商名称",
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
          "id": $("#remoteDataAgent").data("id"),
          "text": (isNaN($("#remoteDataAgent").data("name")) ? $("#remoteDataAgent").data("name") : "搜索代理商名称")
        } //初始化数据
      );;
    };
  })(this));



});





/****** 总订单 新建 子订单 --- 价格 与 板料厚度、材质、颜色 的联动逻辑  开始 ******/
  /**
   * Ajax 获取指定 板料价格
   */
function getMaterialPrice(obj){
  var fields = $(obj).parents(".fields");
  var ply = fields.find(".material-ply").val();
  var texture = fields.find(".material-texture").val();
  var color = fields.find(".material-color").val();
  //alert("ply: " + ply + " texture: " + texture + " color: " + color);
  $.ajax({
    url: "/materials/find/",
    dataType: 'json',
    data: {ply: ply, texture: texture, color: color},
    type: 'POST',
    success: function(data){
      if(data != null){
        fields.find(".material-uom").val(data.uom);
        fields.find(".material-price").val(data.price);
        fields.find(".material-uom").val(data.uom);
      }
      else{
        fields.find(".material-price").val(0);
      }
    },
    error: function(data){
      alert("网络错误！");
    }
  });
}


//全选和反选
function CheckSelect(id){
  var check_boxes = $('.checkbox-'+id);
  for ( var i = 0; i < check_boxes.length; i++)  
  {  
    // 提取控件  
    var checkbox = check_boxes[i];  
    // 检查是否是指定的控件  
    if (checkbox.checked === false)  
    {  
      // 正选  
      checkbox.checked = true;  
    }  
    else if (checkbox.checked === true)  
    {  
      // 反选  
      checkbox.checked = false;  
    }
  }  
}

function download(){
  var ids = new Array();
  var sents_ids = $("#sents_ids");  
  var check_boxes = $('.index_checkbox');
  for ( var i = 0; i < $('.index_checkbox').length; i++){ 
    if(check_boxes[i].checked){
      ids.push(check_boxes[i].value);
    }
  }
  if(ids.length == 0){
    alert("请先选中所要下载的发货信息！");
    return false;
  }

  sents_ids.val(ids);

  url = "/sents/download";
  $("#batch_set").attr('action', url);
}



/****** 总订单 新建 子订单 --- 价格 与 板料厚度、材质、颜色 的联动逻辑  结束 ******/