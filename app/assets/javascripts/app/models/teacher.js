app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",

  initialize : function(ids) {
    alert($(ids).first());
    this.teacherData = this.fetch(
    {        
        url : urlRoot + $(ids).first()        
    });
  }
});