app.views.Teacher = app.views.Base.extend({
  templateName: "teacher",
  tagName: "a",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      teacher : this.model.attributes
    })
  }
});
