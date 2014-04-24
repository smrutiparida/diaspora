app.views.Session = app.views.Base.extend({
  templateName: "session",

  tagName: "li",

  className: "sessionname",

  events: {
    'click .filter-session': 'filterBySession'
  },

  filterBySession: function(evt) {
    
    this.item = $(evt.target);
    app.aspectContentId = this.item.attr('data-id');
    app.router.aspects_stream();
    

    $("#content_id").replaceWith(
      $("<input/>", {
        name: "s_id",
        type: "hidden",
        value: app.aspectContentId,
        id: "content_id"
      })
    );

  },

  isSessionSelected : function(){
    console.log(this.attributes);
    if(typeof app.aspectContentId === "undefined"){
      return false;
    }
    else if(app.aspectContentId === this.attributes.id){
      return true;
    }
    return false;
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      session : this.attributes,
      isSessionSelected : this.isSessionSelected()
    })
  }
});
