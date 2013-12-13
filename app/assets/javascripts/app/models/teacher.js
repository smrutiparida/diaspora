app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher",

  initialize : function(ids) {
    this.teacherData = this.fetch(ids);
  }

});