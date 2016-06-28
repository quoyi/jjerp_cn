function remove_order(row) {
  if ($(row).parent().parent().attr("id") == "old_table") {
    $("#new_table").append(row);
  } else {
    $("#old_table").append(row);
  }
}

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
      alert('没有下一包了');
      return false;
    }
  } else {
    alert('请先选择当前包装的部件!');
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

function previous() {
  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = JSON.parse(localStorage.getItem("pack"));
  if (val.trim() == '') {
    alert('当前包没有数据。');
    return false;
  }
  if (pack && pack[current_index - 1]) {
    pack[current_index] = val;
    localStorage.setItem("pack", JSON.stringify(pack));
    set_ids(pack, current_index);
    $("#new_table").find("tbody").empty();
    localStorage.setItem("index", current_index - 1);
    $("#new_table").find("tbody").html(pack[current_index - 1]);
    return false;
  } else {
    alert('没有上一包了。');
    return false;
  }
  return false;
}

function print_pages(obj) {
  var order_units_size = $(obj).data("units");
  if (order_units_size == "" || order_units_size == 0) {
    alert("没有打包数据，请确认！");
    return false;
  }
  var old_table = $("#old_table").find("tbody").html().trim();
  if (old_table != '') {
    alert('您还没有拆分完所有包装，请继续选择完再进行批量打印');
    return false;
  } else {
    // 弹出模态框，获取输入的数据
    // $("#packageInputNumber").modal('show');
    var number = prompt("请输入标签总数：", "");
    $("#order_label_size").val(number);
    var pack = {};
    if (localStorage.getItem("pack")) {
      pack = JSON.parse(localStorage.getItem("pack"));
    }
    var current_index = parseInt(localStorage.getItem("index"));
    var val = $("#new_table").find("tbody").html();
    if (!pack[current_index]) {
      pack[current_index] = val;
      localStorage.setItem("pack", JSON.stringify(pack));
    }
    // print
    set_ids(pack, current_index);
  }
  // return false;
}

function print_current_page() {
  var old_table = $("#old_table").find("tbody").html().trim();

  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = {};
  if (localStorage.getItem("pack")) {
    pack = JSON.parse(localStorage.getItem("pack"));
  }
  if (val.trim() == '') {
    alert('当前包没有数据。');
    return false;
  }

  if (val) {
    if (pack[current_index - 1]) {
      alert('上一包还没打印呢，请先打印上一包！');
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
    alert('请先选择当前包装的部件!');
    return false;
  }
}

function set_ids(pack, current_index) {
  var r = pack[current_index].match(/<tr.*?id=(.*?)>/g);
  values = $("#order_unit_ids").val();

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