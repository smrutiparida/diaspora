app.collections.Documents = Backbone.Collection.extend({
  url : "/documents",

  model: function(attrs, options) {
    var modelClass = app.models.Document
    return new modelClass(attrs, options);
  },

  parse: function(resp){
    return resp.documents;
  }
});
