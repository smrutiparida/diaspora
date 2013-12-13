app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/"
},

  get_teacher : function(ids) {
    var teacher = new app.models.Teacher();
    teacher.deferred = teacher.fetch({url : teacher.urlRoot + ids[0]})
    return teacher  
  }


});