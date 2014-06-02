app.views.Report = app.views.Base.extend({
  templateName: "report",
  //tagName: "a",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
    
      IsUserTeacher: this.IsUserTeacher(),
      getActiveAspect: this.getActiveAspect()
    })
  },

  IsUserTeacher:function(){
    return_val = app.currentUser.get('role') == "teacher";
    console.log(return_val)
    return return_val;
  },

  getActiveAspect:function(){
  	var ids = app.aspects.selectedAspects('id')
  	if(ids.length > 0){
      console.log(ids[0])
  		return ids[0]
  	}
  	return ""
  }
});

 