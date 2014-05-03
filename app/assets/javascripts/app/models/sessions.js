app.models.Sessions = Backbone.Model.extend({
  urlRoot : "/contents/",

  getSessions : function(ids) {
    app.aspectContentId = "all";
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
      $("#sessions_list").empty();
      
      for (var key in this.attributes) {
        var ele = this.attributes[key].content;
        var tempSessionView = new app.views.Session({attributes: ele});
        $("#sessions_list").append(tempSessionView.render().el);  
        app.aspectContentId = ele.id;
        //tmpl = tmpl + _.template('<li class="sessions-names"><a href="#" class="filter-sessoion" data-aspect="<%= aspect_id %>"><%= name %></a></li>',{'aspect_id':ele.aspect_id,'name':ele.name});  
      }
      $("#sessions_list").slideDown();

      $("#content_id").replaceWith(
        $("<input/>", {
          name: "content_id",
          type: "hidden",
          value: app.aspectContentId,
          id: "content_id"
        })
      ); 
    
      //$('#sessions_list').html(tmpl);
    }
  }
});