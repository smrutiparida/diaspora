app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher",

  initialize : function(ids) {
    this.teacherData = this.fetch(
    {        
        url : urlRoot,
        data : { 'a_ids': ids }
    });
  

});