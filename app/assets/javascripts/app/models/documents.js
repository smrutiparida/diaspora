app.models.Document = Backbone.Model.extend(_.extend({}, app.models.formatDateMixin, {
  urlRoot : "/documents",

  initialize : function() {
  	alert("app.models.Document");
  },

}));
