app.views.Photo = app.views.Base.extend({

  templateName: "photo",

  className : "photo loaded",

  initialize : function() {
  	alert("app.views.Photo");
    $(this.el).attr("id", this.model.get("guid"));
    this.model.bind('remove', this.remove, this);
    return this;
  }
  
});