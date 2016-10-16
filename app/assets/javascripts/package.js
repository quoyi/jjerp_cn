function remove_order(row) {
  if ($(row).parent().parent().attr("id") == "old_table") {
    $("#new_table").append(row);
  } else {
    $("#old_table").append(row);
  }
}

/**
 * 包装 -- 下一页 按钮
 * @return {Function} [description]
 */
function next() {
  var old_table = $("#old_table").find("tbody").html().trim();

  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = {};
  if (localStorage.getItem("pack")) {
    pack = JSON.parse(localStorage.getItem("pack"));
  }

  if (val.trim() != '') {
    pack[current_index] = val;
    localStorage.setItem("pack", JSON.stringify(pack));
    set_ids(pack, current_index);

    if (old_table != "" || pack[current_index + 1]) {
      localStorage.setItem("index", current_index + 1);
      $("#new_table").find("tbody").empty();
      if (pack[current_index + 1]) {
        $("#new_table").find("tbody").html(pack[current_index + 1]);
      }
    } else {
      jsNoty("没有下一包了", "information");
      return false;
    }
  } else {
    jsNoty("当前包未添加部件！", "warning");
    return false;
  }


  return false;

  // tr = $("#new_table").find("tbody").find('tr');
  // for(var i=0; i<tr.length; i++){
  //   var td = $(tr[i]).find('td').last().text();
  //   pack.push(td);
  // }
  // localStorage.setItem(time, pack);


}

/**
 * 包装 -- 上一页 按钮
 * @return {[type]} [description]
 */
function previous() {
  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = JSON.parse(localStorage.getItem("pack"));
  // if (val.trim() == '') {
  //   jsNoty("当前包没有数据。", "information");
  //   return false;
  // }
  if (pack && pack[current_index - 1]) {
    pack[current_index] = val;
    localStorage.setItem("pack", JSON.stringify(pack));
    set_ids(pack, current_index);
    $("#new_table").find("tbody").empty();
    localStorage.setItem("index", current_index - 1);
    $("#new_table").find("tbody").html(pack[current_index - 1]);
    return false;
  } else {
    jsNoty("没有上一包了。", "information");
    return false;
  }
  return false;
}

/**
 * 包装 -- 打印当前页 按钮
 * @return {[type]} [description]
 */
function print_current_page() {
  var old_table = $("#old_table").find("tbody").html().trim();

  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = {};
  if (localStorage.getItem("pack")) {
    pack = JSON.parse(localStorage.getItem("pack"));
  }
  if (val.trim() == '') {
    jsNoty("当前包没有数据。", "error");
    return false;
  }

  if (val) {
    if (pack[current_index - 1]) {
      jsNoty("上一包未打印，请先打印上一包！", "warning");
      return false;
    } else {
      if (!pack[current_index]) {
        pack[current_index] = val;
        localStorage.setItem("pack", JSON.stringify(pack));
      }
      // print
      $("#order_unit_ids").val('');
      set_ids(pack, current_index);
    }

  } else {
    jsNoty("请选择当前包装的部件！", "error");
    return false;
  }
}

/**
 * 包装 -- 批量打印 按钮
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function print_pages(obj) {
  var order_units_size = $(obj).data("units");
  if (order_units_size == "" || order_units_size == 0) {
    jsNoty("所有部件均已打包，请选择重新打印！", "error");
    // 所有部件均已打包，请选择重新打印
    return false;
  }
  var old_table = $("#old_table").find("tbody").html().trim();
  var new_table = $("#new_table").find("tbody").html().trim();
  var tables = old_table + new_table;
  if (old_table == '') {
    //alert('您还没有拆分完所有包装，请继续选择完再进行批量打印');
    return false;
  } else { // 未打包 & 已打包 中只要存在数据，就可以批量打印
    // 弹出模态框，获取输入的数据
    var number = prompt("请输入标签总数：", "");
    if(isNaN(parseInt(number)) || number == null || number == 0 || number < 0){
      jsNoty("请输入正确的标签总数！", "error");
      return false;
    }else{
      $("#order_label_size").val(number);
      var pack = {};
      if (localStorage.getItem("pack")) {
        pack = JSON.parse(localStorage.getItem("pack"));
      }
      var current_index = parseInt(localStorage.getItem("index"));
      var val = $("#new_table").find("tbody").html();
      // old table 也加入打包
      var old_val = $("#old_table").find("tbody").html();
      if (!pack[current_index]) {
        pack[current_index] = val + old_val;
        localStorage.setItem("pack", JSON.stringify(pack));
      }
      // print
      set_ids(pack, current_index);
    }
  }
  // return false;
}

/**
 * 重新打印
 * @param  {[type]} obj [description]
 * @return {[type]}     [description]
 */
function reprint(obj){
  var order_id = $(obj).data("oid"); 

  $.ajax({
    url: '/orders/' + order_id + "/reprint.pdf",
    type: 'POST',
    dataType: 'json',
    data: {length: $("#package_label_length").val(), width: $("#package_label_width").val()},
    success: function(data){
      jsNoty("重新打印成功！", "success");
    }
  });
}


function set_ids(pack, current_index) {
  var r = pack[current_index].match(/<tr.*?id=(.*?)>/g);
  var values = $("#order_unit_ids").val();

  if (values == "") {
    values = JSON.parse("{}");
  } else {
    values = JSON.parse(values)
  }

  values[current_index] = new Array();
  for (var i = 0; i < r.length; i++) {
    var id = r[i].replace(/<tr.*?id=\"/, '').replace(/\">/, '');
    values[current_index].push(id);
  }

  $("#order_unit_ids").val(JSON.stringify(values));
}

$(function() {
  // 设置输入框自动获得焦点
  $("#unit_part_craft_name").focus();
  // 输入框获得焦点后，点击enter（keyCode=13）后的处理逻辑
  $("#unit_part_craft_name").on('keydown', function(e) {
    var value = $("#unit_part_craft_name").val();
    var enter = window.event || e;
    if (enter.keyCode == 13) {
      var trs = $("#old_table").find("tbody").children();
      var not_package_ids = new Array();
      for (var i = 0; i < trs.length; i++) {
        var name = $("#" + trs[i].id).children().first().text();
        if (name != null && name != "" && name == value) {
          $("#" + trs[i].id).click();
          break;
        }
      }
    }
  })
});

// function add_to_packaged(e) {
//   var enter = window.event || e;
//   if (enter.keyCode == 13) {
//     alert("点击确定按钮");
//   }
// }

function reprint_set_label_size(){
  var number = prompt("请输入标签总数：", "");
  if(isNaN(parseInt(number)) || number == null || number == 0 || number < 0){
    jsNoty("请输入正确的标签总数！", "error");
    return false;
  }
  $("#label_size").val(number);
}