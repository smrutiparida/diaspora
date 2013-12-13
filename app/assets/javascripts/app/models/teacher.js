app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",
  teacherData : {},

  initialize : function(ids) {        
    this.teacherData.fetch(
    {        
        url : this.urlRoot + ids[0]        
    });
  }
});