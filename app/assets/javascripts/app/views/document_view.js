app.views.Document = app.views.Base.extend({

  templateName: "document",

  className : "document loaded",

  tagName: "div",

  className: 'hoverable',

  events: {
    'click .icons-check_yes_ok+a': 'toggleShowDeleteButton'
  },

  showDelete: function(evt) {
    if (evt) { evt.preventDefault(); };
    this.model.toggleSelected();
    this.$el.find('.icons-check_yes_ok').toggleClass('selected');
    app.router.aspects_stream();
  },
  initialize : function() {
    alert("came to find document");
    $(this.el).attr("id", this.model.get("guid"));
    this.model.bind('remove', this.remove, this);
    return this;
  }
  
});