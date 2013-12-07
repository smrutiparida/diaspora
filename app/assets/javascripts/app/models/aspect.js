app.models.Aspect = Backbone.Model.extend({
  toggleSelected: function(){
  	//this.map(function(a){ a.set({ 'selected' : false })} );
    this.set({'selected' : true});
  }
});
