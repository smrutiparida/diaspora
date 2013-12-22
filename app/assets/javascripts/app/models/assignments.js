app.models.Assignments = Backbone.Model.extend(_.extend({}, app.models.formatDateMixin, {
  urlRoot : "/assignments",

  initialize : function() {
  	alert("app.models.Assignments");
  },

}));
