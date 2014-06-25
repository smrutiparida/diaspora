app.views.StreamPost = app.views.Post.extend({
  templateName: "stream-element",
  className : "stream_element loaded",

  subviews : {
    ".feedback" : "feedbackView",
    ".likes" : "likesInfoView",
    ".comments" : "commentStreamView",
    ".post-content" : "postContentView",
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    ".status-message-location" : "postLocationStreamView"
    //,
    //".documents" : "documentsView"
  },

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .show_nsfw_post": "removeNsfwShield",
    "click .toggle_nsfw_state": "toggleNsfwState",

    "click .remove_post": "destroyModel",
    "click .hide_post": "hidePost",
    "click .block_user": "blockUser",
    "click .mark_resolved": "resolvePost",
    "click .edit_post": "editPost",
  },

  tooltipSelector : ".timeago, .post_scope, .block_user, .delete, .edit, .resolve",

  initialize : function(){
    this.model.bind('remove', this.remove, this);
    //alert("app.views.StreamPost:initialize");
    //subviews
    this.commentStreamView = new app.views.CommentStream({model : this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.OpenGraph({model : this.model});
  },
  
  //documentsView : function(){
  //  return new app.views.Documents({model : this.model});
  //},

  likesInfoView : function(){
    return new app.views.LikesInfo({model : this.model});
  },

  feedbackView : function(){
    if(!app.currentUser.authenticated()) { return null }
    return new app.views.Feedback({model : this.model});
  },

  postContentView: function(){
    //alert("app.views.StreamPost:postContentView");
    var normalizedClass = this.model.get("post_type").replace(/::/, "__")
      , postClass = app.views[normalizedClass] || app.views.StatusMessage;
    //alert(normalizedClass);    
    return new postClass({ model : this.model })
  },

  postLocationStreamView : function(){
    return new app.views.LocationStream({ model : this.model});
  },

  removeNsfwShield: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.set({nsfw : false})
    this.render();
  },

  toggleNsfwState: function(evt){
    if(evt){ evt.preventDefault(); }
    app.currentUser.toggleNsfwState();
  },


  blockUser: function(evt){
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('ignore_user'))) { return }

    var personId = this.model.get("author").id;
    var block = new app.models.Block();

    block.save({block : {person_id : personId}}, {
      success : function(){
        if(!app.stream) { return }

        _.each(app.stream.posts.models, function(model){
          if(model.get("author").id == personId) {
            app.stream.posts.remove(model);
          }
        })
      }
    })
  },

  remove : function() {
    $(this.el).slideUp(400, _.bind(function(){this.$el.remove()}, this));
    return this
  },

  hidePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('confirm_dialog'))) { return }

    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    })

    this.remove();
  },

  editPost : function(evt) {
    if(evt) { evt.preventDefault(); }
    
    jQuery.facebox('<form accept-charset="UTF-8" action="/posts/' + this.model.id + '" method="POST" data-remote="true"><label><b>Edit Question</b></label><br><textarea cols="40" name="text" rows="4">' + this.model.get("text") +'</textarea><div><input class="button" name="cancel" type="button" value="Cancel" onclick="$(this).bind(\'ajax:success\', function(){ $.facebox.close();alert(1);});" style="float:right;"><input class="button creation" name="commit" type="submit" value="Submit"  style="float:right;" onclick="$.facebox.close(); app.router.aspects_stream();"></div><input type="hidden" name="type" value="edit" /><input type="hidden" name="_method" value="put" /></form>');
  },

  resolvePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    

    $.ajax({
      url : "/posts/" + this.model.id,
      type : "PUT",
      data : {
        type : "resolve"
      }
    })

    app.router.aspects_stream();
    //remove comment area
    //change background color
    //this.$el.addClass("comment_endorsed");
    //this.$(".new_comment_form_wrapper").toggleClass("hidden");
    //this.$(".comment_box").toggle();
    //this.$(".mark_resolved").attr('title','Undo');
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new_comment_form_wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  }

})
