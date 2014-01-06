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

function createUploader(){
 var uploader = new qq.FileUploaderBasic({
     element: document.getElementById('file-upload'),
     params: {},
     allowedExtensions: ['csv'],
     action: "/grades/parse",
     button: document.getElementById('file-upload'),
     sizeLimit: 4194304,

     onProgress: function(id, fileName, loaded, total){
      var progress = Math.round(loaded / total * 100 );
       $('#fileInfo').text(fileName + ' ' + progress + '%');
     },

     messages: {
         typeError: "File of wrong extension",
         sizeError: "Filesize too large. Supported size is till 4 MB",
         emptyError: "Empty file loaded."
     },

     onSubmit: function(id, fileName){
      $('#file-upload').addClass("loading");
      $("#file-upload-spinner").removeClass("hidden");
     },

     onComplete: function(id, fileName, responseJSON){
      $("#file-upload-spinner").addClass("hidden");
      $('#fileInfo').text(fileName + ' completed').fadeOut(2000);
      $('#file-upload').removeClass("loading");
      if ( responseJSON.success = 'success')
      {
         
          var data2 = new google.visualization.arrayToDataTable(responseJSON.students);
          var table = new google.visualization.Table(document.getElementById('table_div'));
          table.draw(data2, {showRowNumber: true});
      }
      else
      {
        $('#fileInfo').text(responseJSON.message);
      }
      

      
     }
 });
}
