app.views.Post = app.views.Base.extend({
  presenter : function() {
    alert("app.views.Post:presenter");
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser(),
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  authorIsCurrentUser : function() {
    alert("app.views.Post:authorIsCurrentUser");
    return app.currentUser.authenticated() && this.model.get("author").id == app.user().id
  },

  showPost : function() {
    alert("app.views.Post:showPost");
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw")
  }
}, { //static methods below

  showFactory : function(model) {
    alert("app.views.Post:showFactory");
    var frameName = model.get("frame_name");

    //translate obsolete template names to the new Moods, should be removed when template picker comes client side.
    var map = {
      'status-with-photo-backdrop' : 'Wallpaper', //equivalent
      'status' : 'Day', //equivalent
      'note' : 'Newspaper', //equivalent
      'photo-backdrop' : 'Day' //that theme was bad
    }

    frameName = map[frameName] || frameName

    return new app.views.Post[frameName]({
      model : model
    })

    function legacyShow(model) {
      alert("app.views.Post:legacyShow");
      return new app.views.Post.Legacy({
        model : model,
        className :   frameName + " post loaded",
        templateName : "post-viewer/content/" +  frameName
      });
    }
  }
});

app.views.Post.Legacy = app.views.Post.extend({
  tagName : "article",
  initialize : function(options) {
    this.templateName = options.templateName || this.templateName
  }
})
