function searchOrDownload(el, type){
  var form = $(el).parent("form"); 
  if(type == 'search'){
    form.attr("action", "/incomes");
  }else {
    form.attr("action", "/incomes.xls");
  }
  form.submit();
}
