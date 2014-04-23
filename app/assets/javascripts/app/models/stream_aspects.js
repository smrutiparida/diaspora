app.models.StreamAspects = app.models.Stream.extend({

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath()
  },

  initialize : function(models, options){
    var collectionClass = options && options.collection || app.collections.Posts;
    this.items = new collectionClass([], this.collectionOptions());
    this.aspects_ids = options.aspects_ids;
    this.session_id = options.session_id;
  },

  basePath : function(){
    return '/aspects';
  },

  fetch: function() {
    if(this.isFetching()){ return false }
    var url = this.url();
    var ids = this.aspects_ids;
    this.deferred = this.items.fetch({
        add : true,
        url : url,
        data : { 'a_ids': ids, 's_id': this.session_id }
    }).done(_.bind(this.triggerFetchedEvents, this))
  }
});
