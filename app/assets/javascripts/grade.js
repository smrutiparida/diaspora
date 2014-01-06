/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function(){

  $('.grade-wrapper').live('click', function(){
    var conversation_path = $(this).data('conversation-path');

    $.getScript(conversation_path);

    return false;
  });

  $('#publish-button').click(function(){
    var assignment_id = $(this).data('id');
    $(this).text("Publishing...");
    
    $.getJSON('/assignment_assessments/publish?a_id=' + assignment_id, function(data) {
      Diaspora.page.flashMessages.render({ 'success':data.success, 'notice':data.message });
      $('#publish-button').text("Published");
      $('#publish-button').attr('class','button disabled');
    });

    return false;
  });


});