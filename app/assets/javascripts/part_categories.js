$(function(){
  $("#editPartCategory").on('show.bs.modal', function(e){
    if (e != null && e.relatedTarget != null) {
      var id = e.relatedTarget.dataset.id;
      var name = e.relatedTarget.dataset.name;
      $(this).find("#part_category_id").val(id);
      $(this).find("#part_category_name").val(name);
    }
    
  });


  $("#part_category_form").on('submit', function(e){
    e.preventDefault();
    console.log($(this));
    var fData = $(this).serializeJSON();
    $.ajax({
      url: "/part_categories/" + fData.id,
      data: fData,
      dataType: "json",
      type: 'PATCH',
      success: function(data){
        window.location.reload();
        jsNoty("更新成功！", "success");
      },
      error: function(data){
        jsNoty("网络错误，无法更新配件类型！", "error");
      }
    });
  });
});