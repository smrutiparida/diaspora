app.views.Session = app.views.Base.extend({
  templateName: "session",

  tagName: "li",

  className: "sessionname",

  events: {
    'click .filter-session': 'filterBySession'
  },

  filterBySession: function(evt) {
    //if (evt) { evt.preventDefault(); };
    //this.model.toggleSelected();    
    //$('.all_aspects').find('.icons-check_yes_ok').removeClass('selected');
    //this.$el.find('.icons-check_yes_ok').addClass('selected');
    //alert("called");
    this.item = $(evt.target);
    console.log(this.item)
    app.aspectSessionId = this.item.attr('data-id');
    console.log(app.aspectSessionId)
    
    app.router.aspects_stream();
    
    $('#sessions_list').find('.sessionname').removeClass('selected');
    this.item.addClass('selected');

    $("#session_id").replaceWith(
      $("<input/>", {
        name: "s_id",
        type: "hidden",
        value: app.aspectSessionId,
        id: "session_id"
      })
    );

  },

  presenter : function() {
    //console.log("came to the presenter");
    //console.log(this.attributes);
    return _.extend(this.defaultPresenter(), {
      session : this.attributes
    })
  }
});
