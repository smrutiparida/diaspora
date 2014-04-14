app.views.Sessions = app.views.Base.extend({

  templateName : "sessions",

  className : "sessions",

  tagName : "li",

  presenter : function() {
    console.log(this.options.sessions.content);
    return _.extend(this.defaultPresenter(), {
      sessions : this.options.sessions.content
    })
    
  }


});
