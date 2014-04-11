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
 
    this.model.on("change", this.render, this)
    console.log("came to teacherComment" + this.model.get("author").diaspora_id + " " + this.model.get("parent").author.diaspora_id)
    console.log(app.teacherModel.attributes.handle);
    if(this.model.get("author").diaspora_id == app.teacherModel.attributes.handle){
      console.log("came")
      this.className += " teacher_comment";
    }
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
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

    return t;
  }
});

app.views.ExpandedComment = app.views.Comment.extend({
  postRenderTemplate : function(){
  }
});
