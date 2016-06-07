function remove_order (row) {
  if($(row).parent().parent().attr("id") == "old_table"){
    $("#new_table").append(row);
  }else{
    $("#old_table").append(row);  
  }
}

function next(){
  var old_table = $("#old_table").find("tbody").html().trim();

  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = {};
  if(localStorage.getItem("pack")){
    pack = JSON.parse(localStorage.getItem("pack"));
  }

  if(val){
    pack[current_index] = val;
    localStorage.setItem("pack", JSON.stringify(pack));
    set_ids(pack, current_index);

    if(old_table != "" || pack[current_index+1]){
      localStorage.setItem("index", current_index+1);
      $("#new_table").find("tbody").empty();
      if(pack[current_index+1]){
        $("#new_table").find("tbody").html(pack[current_index+1]);
      } 
    }else{
      alert('没有下一包了');
      return false;
    }
  }else{
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

function previous(){
  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = JSON.parse(localStorage.getItem("pack"));
  if( pack && pack[current_index-1]){
    pack[current_index] = val;
    localStorage.setItem("pack", JSON.stringify(pack));
    set_ids(pack, current_index);
    $("#new_table").find("tbody").empty();
    localStorage.setItem("index", current_index-1);
    $("#new_table").find("tbody").html(pack[current_index-1]);
    return false;
  }else{
    alert('没有上一包了。');
    return false;
  }
  return false;
}

function print_pages(){
  var old_table = $("#old_table").find("tbody").html().trim();

  if(old_table != ''){
    alert('您还没有拆分完所有包装，请继续选择完再进行批量打印');
    return false;
  }else{
    var pack = JSON.parse(localStorage.getItem("pack"));
    var current_index = parseInt(localStorage.getItem("index"));
    var val = $("#new_table").find("tbody").html();
    if(!pack[current_index]){
      pack[current_index] = val;
      localStorage.setItem("pack", JSON.stringify(pack));
      set_ids(pack, current_index)
    }
    // print
  }
}

function print_current_page(){
  var old_table = $("#old_table").find("tbody").html().trim();

  var current_index = parseInt(localStorage.getItem("index"));
  var val = $("#new_table").find("tbody").html();
  var pack = {};
  if(localStorage.getItem("pack")){
    pack = JSON.parse(localStorage.getItem("pack"));
  }
  if(val){
    if(pack[current_index-1]){
      alert('上一包还没打印呢，请先打印上一包！');
      return false;
    }else{
      if(!pack[current_index]){
        pack[current_index] = val;
        localStorage.setItem("pack", JSON.stringify(pack));
      }
      // print
      $("#order_unit_ids").val('');
      set_ids(pack, current_index);
    }

  }else{
    alert('请先选择当前包装的部件!');
    return false;
  }
}

function set_ids(pack, current_index){

  var r = pack[current_index].match(/<tr.*?id=(.*?)>/g);
  values = $("#order_unit_ids").val();

  if(values == ""){
     values = JSON.parse("{}");
   }else{
     values = JSON.parse(values)
   }
 
  values[current_index] = new Array();
  for(var i=0; i<r.length; i++){
    var id = r[i].replace(/<tr.*?id=\"/, '').replace(/\">/,'');
    values[current_index].push(id);
  }
  $("#order_unit_ids").val(JSON.stringify(values));
}

