app.views.Session = app.views.Base.extend({
  templateName: "session",

  tagName: "li",

  className: "sessionname",

  events: {
    'click .filter-session': 'filterBySession'
  },

  filterBySession: function(evt) {
    
    this.item = $(evt.target);
    app.aspectContentId = this.item.attr('data-id');
    app.router.aspects_stream();
    
    $('#sessions_list').find('.sessionname').removeClass('selected');
    this.item.parent().addClass('selected');

    $("#content_id").replaceWith(
      $("<input/>", {
        name: "s_id",
        type: "hidden",
        value: app.aspectContentId,
        id: "content_id"
      })
    );

  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      session : this.attributes
    })
  }
});
