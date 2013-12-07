app.models.Aspect = Backbone.Model.extend({
  toggleSelected: function(){
  	//this.map(function(a){ a.set({ 'selected' : false })} );
  	app.aspects.deselectAll();
    this.set({'selected' : true });
  }
});
