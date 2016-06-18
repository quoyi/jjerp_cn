$(function() {
  $("[data-provide=datepicker]").datepicker({
    format: 'yyyy-mm-dd',
    language: 'zh-CN',
    autoclose: true
  }).on('changeDate', function(e) {
    var targetId = $(this).attr('id');
    
    // 下单时间默认值
    // if(targetId == 'indent_verify_at'){
    //   var d = e.date;
    //   var indent_at = d.setDate(d.getDate() + 10);
    //   alert(indent_at);
    //   $('#indent_require_at').val(e.date);
    // }

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

  // var now = new Date();
  // $("#indent_verify_at").val(now);
  // $("#indent_require_at").val(now.setDate(now.getDate() + 10));

  $("#addIncomes").on('show.bs.modal', function(e){
    var indent_id = e.relatedTarget.dataset.indent;
    $("#income_indent_id").val(indent_id);
  });

  //ajax动态搜索组团社联系人
  return $('#remoteDataAgent').each((function(_this) {
    return function(i, e) {
      var options, select;
      select = $(e);
      options = {
        placeholder: "经销商名称",
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
      return select.select2(options).select2("data",
     {"id": $("#remoteDataAgent").data("id"),"text":(isNaN($("#remoteDataAgent").data("name")) ? $("#remoteDataAgent").data("name") : "搜索经销商名称")}  //初始化数据
    );;
    };
  })(this));


});