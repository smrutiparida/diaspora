app.views.Session = app.views.Base.extend({
  templateName: "session",

  tagName: "li",

  events: {
    'click session-names': 'filterBySession'
  },

  filterBySession: function(evt) {
    if (evt) { evt.preventDefault(); };
    //this.model.toggleSelected();    
    //$('.all_aspects').find('.icons-check_yes_ok').removeClass('selected');
    //this.$el.find('.icons-check_yes_ok').addClass('selected');
    alert("called");
    app.router.aspects_stream();
  },

  presenter : function() {
    console.log("came to the presenter");
    console.log(this.model);
    return _.extend(this.defaultPresenter(), {
      session : this.model
    })
  }
});
