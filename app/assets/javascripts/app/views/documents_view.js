app.views.Documents = app.views.InfScroll.extend({
  initialize : function(options) {
    this.stream = this.model;
    this.collection = this.stream.items;

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
