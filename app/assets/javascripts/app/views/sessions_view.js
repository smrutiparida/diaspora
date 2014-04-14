app.views.Sessions = app.views.Base.extend({

  templateName : "sessions",

  className : "sessions",

  tagName : "li",

  presenter : function() {
    console.log(this.sessions);
    return _.extend(this.defaultPresenter(), {
      sessions : this.sessions
    })
    
  }


});
