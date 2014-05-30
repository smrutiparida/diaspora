app.views.Report = app.views.Base.extend({
  templateName: "report",
  //tagName: "a",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      reports : this.attributes,
      IsUserTeacher: this.IsUserTeacher(),
      getActiveAspect: this.getActiveAspect()
    })
  },

  IsUserTeacher:function(){
    return app.currentUser.get('role') == "teacher"
  },

  getActiveAspect:function(){
  	var ids = app.aspects.selectedAspects('id')
  	if(ids.length > 0){
  		return ids[0]
  	}
  	return ""
  }
});

 