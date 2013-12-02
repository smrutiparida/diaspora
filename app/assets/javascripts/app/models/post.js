app.models.Post = Backbone.Model.extend(_.extend({}, app.models.formatDateMixin, {
  urlRoot : "/posts",

  initialize : function() {
    //alert("app.models.Post:initialize");
    this.interactions = new app.models.Post.Interactions(_.extend({post : this}, this.get("interactions")))
    this.delegateToInteractions()
  },

  delegateToInteractions : function(){
    //alert("app.models.Post:delegateToInteractions");
    this.comments = this.interactions.comments
    this.likes = this.interactions.likes

    this.comment = function(){
      this.interactions.comment.apply(this.interactions, arguments)
    }
  },

  setFrameName : function(){
    //alert("app.models.Post:setFrameName");
    this.set({frame_name : new app.models.Post.TemplatePicker(this).getFrameName()})
  },

  applicableTemplates: function() {
    //alert("app.models.Post:applicableTemplates");
    return new app.models.Post.TemplatePicker(this).applicableTemplates()
  },

  interactedAt : function() {
    //alert("app.models.Post:interactedAt");
    return this.timeOf("interacted_at");
  },

  reshare : function(){
    //alert("app.models.Post:reshare");
    return this._reshare = this._reshare || new app.models.Reshare({root_guid : this.get("guid")});
  },

  reshareAuthor : function(){
    //alert("app.models.Post:reshareAuthor");
    return this.get("author")
  },

  toggleFavorite : function(options){
    //alert("app.models.Post:toggleFavorite");
    this.set({favorite : !this.get("favorite")})

    /* guard against attempting to save a model that a user doesn't own */
    if(options.save){ this.save() }
  },

  headline : function() {
    //alert("app.models.Post:headline");
    var headline = this.get("text").trim()
      , newlineIdx = headline.indexOf("\n")
    return (newlineIdx > 0 ) ? headline.substr(0, newlineIdx) : headline
  },

  body : function(){
    //alert("app.models.Post:body");
    var body = this.get("text").trim()
      , newlineIdx = body.indexOf("\n")
    return (newlineIdx > 0 ) ? body.substr(newlineIdx+1, body.length) : ""
  },

  //returns a promise
  preloadOrFetch : function(){
    //alert("app.models.Post:preloadOrFetch");
    var action = app.hasPreload("post") ? this.set(app.parsePreload("post")) : this.fetch()
    return $.when(action)
  },

  hasPhotos : function(){
    //alert("app.models.Post:hasPhotos");
    return this.get("photos") && this.get("photos").length > 0
  },

  hasDocuments : function(){
    //alert("app.models.Post:hasDocuments");
    return this.get("documents") && this.get("documents").length > 0
  },

  hasText : function(){
    //alert("app.models.Post:hasText");
    return $.trim(this.get("text")) !== ""
  }
}), {
  headlineLimit : 118,

  frameMoods : [
    "Wallpaper",
    "Vanilla",
    "Typist",
    "Fridge"
  ]
});
