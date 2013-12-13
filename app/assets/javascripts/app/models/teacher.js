app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",

  initialize : function(ids) {
    alert(ids[0]);
    this.teacherData = this.fetch(
    {        
        url : this.urlRoot + ids[0]        
    });
  }
});