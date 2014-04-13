app.views.Sessions = app.views.Base.extend({

  templateName : "sessions",

  className : "sessions",



  presenter : function() {
    return {sessions : this.sessions}
  }


});
