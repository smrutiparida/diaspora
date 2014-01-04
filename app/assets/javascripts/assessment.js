/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function(){

  $('time.timeago').each(function(i,e) {
    var jqe = $(e);
    jqe.attr('data-original-title', new Date(jqe.attr('datetime')).toLocaleString());
    jqe.attr('title', '');
  });

  $('.timeago').tooltip();
  $('.timeago').timeago();

  $('time.timeago').each(function(i,e) {
    var jqe = $(e);
    jqe.attr('title', '');
  });

  $('.assessment-wrapper').live('click', function(){
    var conversation_path = $(this).data('conversation-path');

    $.getScript(conversation_path, function() {
      Diaspora.page.directionDetector.updateBinds();
    });

    return false;
  });


});