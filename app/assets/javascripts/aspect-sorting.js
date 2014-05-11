/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
function createShortForm(text_string){
  var res = text_string.split(" ");
  var text_code = "";
  if(res.length > 1)
  {
    for(var i =0; i < res.length; i++)
    {
      text_code += res[i].substring(0,1);
    }
  }
  else
  {
    text_code = text_string.substring(0, 3);
  }
  
  return text_code;
}


$(document).ready(function() {
  $('#aspect_nav.left_nav .all_aspects .sub_nav').sortable({
    items: "li[data-aspect_id]",
    update: function(event, ui) {
      var order = $(this).sortable("toArray", {attribute: "data-aspect_id"}),
          obj = { 'reorder_aspects': order, '_method': 'put' };
      $.ajax('/user', { type: 'post', dataType: 'script', data: obj });
    },
    revert: true,
    helper: 'clone'
  });

  $('#aspect_name').keypress(function(){
    var short_form = createShortForm($('#aspect_name').val())
    var d = new Date();
    var n = d.getFullYear();
    var course_code = short_form + n.toString();
    $('#course_code').text(course_code);
    $('#course_hidden_code').val(course_code);

  });
});

