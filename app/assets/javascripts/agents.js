$(function(){
  $(".agents_search_form_full_name").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "店名",
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
  $(".agents_search_form_contacts").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "联系人",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/agents.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'contacts',
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
  $(".agents_search_form_mobile").select2({
    language: 'zh-CN',
    theme: 'bootstrap',
    placeholder: "电话",
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: '/agents.json',
      dataType: 'json',
      delay: 250,
      cache: false,
      data: function(params){
        return {
          oftype: 'mobile',
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


function getChinaCity(obj) {
  var element_name = $(obj).attr("name").replace("agent[", "").replace("]", "");
  var data = {};
  if (element_name == "province") {
    var $province = $(obj);
    var $city = $(obj).next();
    var $district = $(obj).next().next();
    $city.empty().append("<option value=''>--城市--</option>");
    $district.empty().append("<option value=''>--地区--</option>");
    $.ajax({
      url: '/areas/find',
      dataType: 'json',
      data: {
        pid: $province.val()
      },
      type: 'get',
      cache: false,
      success: function(data) {
        if (data != "" && data != null) {
          var options = "";
          for (var i = 0; i < data.length; i++) {
            options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>";
          }
          $city.append(options);
        }
      },
      error: function() {
        jsNoty("网络错误！", "error");
      }
    });
  } else if (element_name == "city") {
    var $city = $(obj);
    var $district = $(obj).next();
    $district.empty().append("<option value=''>--地区--</option>");
    $.ajax({
      url: '/areas/find',
      dataType: 'json',
      data: {
        cid: $city.val()
      },
      type: 'get',
      cache: false,
      success: function(data) {
        if (data != "" && data != null) {
          var options = "";
          for (var i = 0; i < data.length; i++) {
            options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>";
          }
          $district.append(options);
        }
      },
      error: function() {
        jsNoty("网络错误！", "error");
      }
    });
  }
}

// 点击市、县时，判断是否有数据
function validateCities(obj) {
  var element_name = $(obj).attr("name").replace("agent[", "").replace("]", "");
  if (element_name == "city") {
    var pid = $(obj).prev().val();
    if ($(obj).children().length <= 1) {
      $(obj).empty().append("<option value=''>--城市--</option>");
      $.ajax({
        url: '/areas/find',
        dataType: 'json',
        data: {
          pid: pid
        },
        type: 'get',
        cache: false,
        success: function(data) {
          if (data != "" && data != null) {
            var options = "";
            for (var i = 0; i < data.length; i++) {
              options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>";
            }
            $(obj).append(options);
          }
        },
        error: function() {
          jsNoty("网络错误！", "error");
        }
      });
    }
  } else if (element_name == "district") {
    var cid = $(obj).prev().val();
    if ($(obj).children().length <= 1) {
      $(obj).empty().append("<option value=''>--地区--</option>");
      $.ajax({
        url: '/areas/find',
        dataType: 'json',
        data: {
          cid: cid
        },
        type: 'get',
        cache: false,
        success: function(data) {
          if (data != "" && data != null) {
            var options = "";
            for (var i = 0; i < data.length; i++) {
              options += "<option value='" + data[i].id + "'>" + data[i].name + "</option>";
            }
            $(obj).append(options);
          }
        },
        error: function() {
          jsNoty("网络错误！", "error");
        }
      });
    }
  }
  // var $cities = $city.children();
  // console.log($cities);
}