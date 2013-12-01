app.collections.Photos = Backbone.Collection.extend({
  url : "/photos",

  model: function(attrs, options) {
  	alert("app.collections.Photos");
    var modelClass = app.models.Photo
    return new modelClass(attrs, options);
  },

  parse: function(resp){
    return resp.photos;
  }
});
