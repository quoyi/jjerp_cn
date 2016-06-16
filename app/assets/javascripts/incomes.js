// $(function() {
//   $("#income-new-usermane").select2({
//     placeholder: "查找用户",
//     minimumInputLength: 1,
//     ajax: {
//       url: "/users.json",
//       dataType: 'json',
//       quietMillis: 300,
//       data: function(search, page) {
//         return {
//           term: search,
//           page_limit: 25,
//           page: page,
//         };
//       },
//       results: function(data, page) {
//         var more = (page * 10) < data.total;
//         return {
//           results: data.users,
//           more: more
//         };
//       }
//     },
//     formatResult: function(user) {
//       var markup = "<ul>";
//       markup += "<li>" + user.name + "</li>";
//       markup += "</ul>"
//       return markup;
//     },
//     formatSelection: function(user) {
//       return ("<input type='hidden' id='user_id' name='department[manager_id]' value=" + user.id + " />" + user.name);
//     }
//   });
// });

