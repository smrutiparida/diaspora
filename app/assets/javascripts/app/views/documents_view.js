app.views.Documents = app.views.InfScroll.extend({
  initialize : function(options) {
    alert("app.views.Documents");
    this.stream = this.model;
    this.collection = this.stream.documents;

    // viable for extraction
    this.stream.fetch();

    this.setupLightbox()
    this.setupInfiniteScroll()
  },

  postClass : app.views.Document,

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");    
    $(this.el).delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);
    
  }
});
