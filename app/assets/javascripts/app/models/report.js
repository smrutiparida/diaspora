app.models.Report = Backbone.Model.extend({
  urlRoot : "/reports/snippet/",

  get_report : function(ids) {
    //var teacher = new app.models.Teacher();
    if(ids.length > 0){
      this.deferred = this.fetch({url : this.urlRoot + ids[0]}).done(_.bind(this.triggerFetchedEvents, this))
    }
    //return teacher;  
  },

  isFetching : function(){
    return this.deferred && this.deferred.state() == "pending"
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    //var respItems = this.parse(resp);
    console.log(this.attributes)
    console.log(resp)

    if(this.attributes.id)
    {
      app.reportView = new app.views.Report({attributes:this.attributes});
      $('#report_snippet').html(app.reportView.render().el);
    }
  }


});