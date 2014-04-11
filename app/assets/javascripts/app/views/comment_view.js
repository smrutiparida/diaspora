//= require ./content_view
app.views.Comment = app.views.Content.extend({
  templateName: "comment",
  className : "comment media",

  events : function() {
    return _.extend({}, app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel"
    });
  },

  initialize : function(options){
    this.templateName = options.templateName || this.templateName
 
    
    //console.log("came to teacherComment" + this.model.get("author").diaspora_id + " " + this.model.get("parent").author.diaspora_id)
    //if(app.teacherModel){
    //  console.log(app.teacherModel.attributes)
    //  console.log(app.teacherModel.get("handle"));
    //  console.log(app.teacherModel);
    //  console.log(app.teacherModel.handle);
    //  console.log(app.teacherModel.toJSON());  
    //}
    
    //if(this.model.get("author").diaspora_id == app.teacherModel.get("handle")){
    //  console.log("came")
    //  this.className = this.className + " teacher_comment";
    //}

    this.model.on("change", this.render, this)
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      teacherComment : this.teacherComment(), 
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  ownComment : function() {
    return app.currentUser.authenticated() && this.model.get("author").diaspora_id == app.currentUser.get("diaspora_id")
  },

  postOwner : function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.diaspora_id == app.currentUser.get("diaspora_id")
  },

  canRemove : function() {
    return app.currentUser.authenticated() && (this.ownComment() || this.postOwner())
  },

  teacherComment : function(){
    if(this.model.get("author").diaspora_id == app.teacherModel.get("handle")){
      return true;
    }
    return false;
  }
});

app.views.ExpandedComment = app.views.Comment.extend({
  postRenderTemplate : function(){
  }
});
