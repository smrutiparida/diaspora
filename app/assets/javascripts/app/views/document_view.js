app.views.Document = app.views.Base.extend({

  templateName: "document",

  className : "document loaded",

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));
    this.model.bind('remove', this.remove, this);
    return this;
  }
  
});