app.models.Teacher = Backbone.Model.extend({
  urlRoot : "/aspects/teacher/",

  get_teacher : function(ids) {
    //var teacher = new app.models.Teacher();
    this.deferred = this.fetch({url : this.urlRoot + ids[0]}).done(_.bind(this.triggerFetchedEvents, this))
    //return teacher;  
  },

  isFetching : function(){
    return this.deferred && this.deferred.state() == "pending"
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    //var respItems = this.parse(resp);
    //alert(this.attributes.id);

    app.teacherView = new app.views.Teacher({attributes:this.attributes});
    $('#aspect_teacher').html(app.teacherView.render().el);
    
    //if(respItems && (respItems.author || respItems.length == 0)) {
    //  this.trigger("allItemsLoaded", this);
    //}
  }


});