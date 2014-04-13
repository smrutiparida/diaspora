app.models.Sessions = Backbone.Model.extend({
  urlRoot : "/contents/show/",

  getSessions : function(ids) {
    this.deferred = this.fetch({url : this.urlRoot + ids[0]}).done(_.bind(this.triggerFetchedEvents, this))
  },

  isFetching : function(){
    return this.deferred && this.deferred.state() == "pending"
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    //var respItems = this.parse(resp);
    if(this.attributes)
    {
      app.sessionsView = new app.views.Sessions({sessions:this.attributes});
      $('##sessions_list').prepend(app.sessionsView.render().el);
    }
  }
});