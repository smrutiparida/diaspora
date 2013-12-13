app.views.Teacher = app.views.Base.extend({
  templateName: "teacher",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      teacher : this.model
    })
  }
});
