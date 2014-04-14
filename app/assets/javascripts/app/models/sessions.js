app.models.Sessions = Backbone.Model.extend({
  urlRoot : "/contents/",

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
      console.log(this);
      console.log(this.attributes)
      //app.sessionsView = new app.views.Sessions({sessions:this.attributes});
      var tmpl = "";
      for (var key in this.attributes) {
        console.log(this.attributes[key]);
        console.log(this.attributes[key].content);
        console.log(this.attributes[key].content.name);
      
        var ele = this.attributes[key].content;
        tmpl = tmpl + _.template('<li><a href="#" class="filter-sessoion" data-aspect="<%= aspect_id %>"><%= name %></a></li>',{'aspect_id':ele.aspect_id,'name':ele.name});  
      }
      $('#sessions_list').prepend(tmpl);
    }
  }
});