app.models.Report = Backbone.Model.extend({
  urlRoot : "/reports/snippet?id=",

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
    
    //var reports = _.map(this.attributes, function(num, key){ return num; });
    console.log(this.attributes)
    app.reportView = new app.views.Report({attributes:this.attributes});
    //app.reportView = new app.views.Report({});
    console.log(app.reportView)
    console.log(app.reportView.render().el)
    $('#report_snippet').html(app.reportView.render().el);
    
  }


});
