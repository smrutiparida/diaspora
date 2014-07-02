app.views.Report = app.views.Base.extend({
  templateName: "report",
  //tagName: "a",
  
  initialize : function(){
    // init shortcut references to the various elements
    this.reports = this.attributes;
  },

  presenter : function() {
    return {
      reports: _.map(this.reports, function(report){
        return _.extend({}, report)
      }),

      IsUserTeacher: this.IsUserTeacher(),
      getActiveAspect: this.getActiveAspect()
    }
  },

  IsUserTeacher:function(){
    return app.currentUser.get('role') == "teacher" || app.currentUser.get('role') == "institute_admin";
  },

  getActiveAspect:function(){
  	var ids = app.aspects.selectedAspects('id')
  	if(ids.length > 0){
      //console.log(ids[0])
  		return ids[0]
  	}
  	return ""
  }
});

 