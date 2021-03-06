app.models.Comment = Backbone.Model.extend({
  urlRoot: "/comments",

  initialize : function() {
    this.likes = new app.collections.LikeComments(this.get("likes"), {comment : this}); 
  },

/*  parse : function(resp){
    console.log("came to parse")
    console.log(resp)
    console.log(this)
    console.log(this.likes)
    //this.likes.reset(resp.likes)
   
    //var likes = this.likes
    //var likes = new app.collections.LikeComments(null, {comment : resp});
    var likes = new app.collections.Likes(null, {post : this.post});
    console.log(likes)  
    return {
      likes : likes,
      fetched : true
    }
  },
*/
  userLike : function(){
    return this.likes.select(function(like){ return like.get("author").guid == app.currentUser.get("guid")})[0]
  },

  like : function() {
    var self = this;
    this.likes.create({}, {success : function(){
      self.trigger("change")
      self.set({"likes_count" : self.get("likes_count") + 1})
    }})

    app.instrument("track", "Like")
  },

  unlike : function() {
    var self = this;
    this.userLike().destroy({success : function(model, resp) {
      self.trigger('change')
      self.set({"likes_count" : self.get("likes_count") - 1})
    }});

    app.instrument("track", "Unlike")
  }

});
