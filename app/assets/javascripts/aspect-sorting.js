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
      if(res[i] != "")
      {
        text_code += res[i].substring(0,1);
      }
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

  $('#aspect_name').live('keyup', function(){
    
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    var short_form = createShortForm($('#aspect_name').val())
    var d = new Date();
    var n = d.getFullYear();

    var uniquePart = $('#course_code').text();
    var uniqueNess = possible.charAt(Math.floor(Math.random() * possible.length)) + Math.floor((Math.random() * 100) + 1).toString();  
    if(uniquePart != ""){
      var part_array = uniquePart.split("-");
      if(part_array.length > 1){
        uniqueNess = part_array[1]
      }
    }

    var course_code = "";
    if (short_form != "")
    {
      course_code = short_form + n.toString() + "-" + uniqueNess;
    }

    $('#course_code').text(course_code);
    $('#course_hidden_code').val(course_code);
  });

  $('#teacher_select').live('change',function(){
    $('.course_per_teacher').attr('disabled', true).hide();
    $('#teacher-label').show();
    $('#teacher_select_' + $(this).val()).attr('disabled', false).show();
  });
});

