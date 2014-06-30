app.models.Comment = Backbone.Model.extend({
  urlRoot: "/comments",

  initialize : function() {
  	console.log(this.get("likes_count"))
  	console.log(this);
  	console.log(this.get("likes_count") > 0)
  	if (this.get("likes_count") > 0){
        
        console.log(this.get('likes'))
  		this.likes = new app.collections.LikeComments(this.get("likes"), {comment : this});  	
  	} else {
  		this.likes = new app.collections.LikeComments(null, {comment : this});  	
  	}

    
  },

  parse : function(resp){
   
    this.likes.reset(resp.likes)
   
    var likes = this.likes
      
    return {
      likes : likes,
      fetched : true
    }
  },

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
