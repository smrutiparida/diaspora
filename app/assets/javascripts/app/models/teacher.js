app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",

  initialize : function(ids) {
    this.aspect_id = ids[0];
    this.teacher_data = new app.models.Teacher
  },

  fetch : function(){
    if(this.isFetching()){ return false }    
    this.deferred = this.teacher_data.fetch({
        url : this.urlRoot + this.aspect_id        
    }).done(_.bind(this.triggerFetchedEvents, this))
  },
   
  isFetching : function(){
    return this.deferred && this.deferred.state() == "pending"
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    var respItems = this.teacher_data.parse(resp);
    if(respItems && respItems.id) {
      this.trigger("allItemsLoaded", this);
    }
  }

});