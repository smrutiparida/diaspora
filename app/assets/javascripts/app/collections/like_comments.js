app.collections.LikeComments = Backbone.Collection.extend({
  model: app.models.Like,

  initialize : function(models, options) {
    this.url = "/comments/" + options.comment.id + "/likes"
  }
});
