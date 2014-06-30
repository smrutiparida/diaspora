//= require ./content_view
app.views.Comment = app.views.Content.extend({
  templateName: "comment",
  className : "comment media",

  events : function() {
    return _.extend({}, app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel",
      "click .comment_best": "endorseComment",
      "click .like" : "toggleLike",
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
      canEndorse: this.canEndorse(),
      teacherCommentORendorsedComment : this.teacherCommentORendorsedComment(), 
      isEndorsedComment : this.isEndorsedComment(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model),
      likesCount: this.likesCount(),
      userLike: this.userLike(),
    })
  },

  likesCount: function(){
    return this.model.get("likes_count");
  },

  userLike:function(){
    return this.model.userLike();
  },

  toggleLike: function(evt) {
    console.log("toggling like")
    if(evt) { evt.preventDefault(); }
    if(this.model.userLike()) {
      this.model.unlike()
    } else {
      this.model.like()
    }
  },

  endorseComment : function(evt) {
      if(evt) { evt.preventDefault(); }
      $.ajax({
        url : "/comments/" + this.model.id,
        type : "PUT",
        data : {
          c_id : this.model.id,
        }
      })

      
      //remove comment area
      //change background color
      this.$('.bd').toggleClass("teacher_comment");
      this.$('.comment_best').attr('title','Undo');
    },

  ownComment : function() {
    return app.currentUser.authenticated() && this.model.get("author").diaspora_id == app.currentUser.get("diaspora_id")
  },

  postOwner : function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.diaspora_id == app.currentUser.get("diaspora_id")
  },

  canRemove : function() {
    return app.currentUser.authenticated() && this.ownComment()
  },

  canEndorse: function(){
    return app.currentUser.authenticated() && app.currentUser.get('role') == "teacher"
  },

  teacherCommentORendorsedComment : function(){
    //console.log(this.model.get("is_endorsed"));
    var is_teachercomment = false;
    if(typeof app.teacherModel != "undefined"){
      is_teachercomment =  (this.model.get("author").diaspora_id == app.teacherModel.get("handle") )
    }
    
    if(app.currentUser.authenticated() && ( is_teachercomment || this.model.get("is_endorsed"))){
      return true;
    }
    //console.log("came");
    return false;
  },
  
  isEndorsedComment : function(){ 
    return this.model.get("is_endorsed")
  },

  likes_fetched : function(){
    this.model.get("fetched")
  }

});

app.views.ExpandedComment = app.views.Comment.extend({
  postRenderTemplate : function(){
  }
});




  




