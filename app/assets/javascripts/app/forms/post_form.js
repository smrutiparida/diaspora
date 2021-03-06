app.forms.Post = app.views.Base.extend({
  templateName : "post-form",
  className : "post-form",

  subviews : {
    ".new_picture" : "pictureForm",
    ".new_document" : "documentForm"
   },

  initialize : function() {
    alert("app.forms.Post");
    this.pictureForm = new app.forms.Picture({model: this.model});
    //this.documentForm = new app.forms.Document({model:this.model});
  },

  postRenderTemplate : function() {
    Mentions.initialize(this.$("textarea.text"));
    Mentions.fetchContacts(); //mentions should use app.currentUser
    this.$('textarea').autoResize({minHeight: '200', maxHeight:'300', animate: false});
  }
});