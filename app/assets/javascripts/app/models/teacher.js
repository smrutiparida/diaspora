app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",
  teacherData : {},

  initialize : function(ids) {        
    this.fetch(
    {        
        url : this.urlRoot + ids[0]        
    }).done(_.bind(this.triggerFetchedEvents, this));
  },

  triggerFetchedEvents : function(resp){
    this.teacherData = this.parse(resp);    
  }
  
});