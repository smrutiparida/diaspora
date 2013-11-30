app.forms.DocumentBase = app.views.Base.extend({
  events : {
    'ajax:complete .new_document' : "documentUploaded",
    "change input[name='document[user_file]']" : "submitForm"
  },

  onSubmit : $.noop,
  uploadSuccess : $.noop,

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
  },

  submitForm : function (){
    this.$("form").submit();
    this.onSubmit();
  },

  documentUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      this.uploadSuccess(resp)
    } else {
      alert("Upload failed!  Please try again. " + resp.error);
    }
  }
});

/* multi photo uploader */
app.forms.Document = app.forms.DocumentBase.extend({
  templateName : "document-form",

  initialize : function() {
    this.documents = this.model.documents || new Backbone.Collection()
    this.documents.bind("add", this.render, this)
  },

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
    this.$("input[name=document_ids]").val(this.documents.pluck("id"))
    this.renderDocuments();
  },

  onSubmit : function (){
    this.$(".documents").append($('<span class="loader" style="margin-left: 80px;"></span>'))
  },

  uploadSuccess : function(resp) {
    this.documents.add(new Backbone.Model(resp.data))
  },

  renderPhotos : function(){
    var photoContainer = this.$(".documents")
    this.photos.each(function(photo){
      var photoView = new app.views.Photo({model : photo}).render().el
      photoContainer.append(photoView)
    })
  }
});
