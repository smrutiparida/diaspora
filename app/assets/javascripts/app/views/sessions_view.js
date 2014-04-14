app.views.Sessions = app.views.Base.extend({

  templateName : "sessions",

  className : "sessions",

  tagName : "li",

  initialize : function(){
    this.sessions = [{aspect_id:"12",name:"smruti"},{aspect_id:"123",name:"hello"}];
    //this.render();
  },

  presenter : function() {
    console.log(this.options.sessions);
    return _.extend(this.defaultPresenter(), {
      sessions : this.sessions
    })
    
  }


});
