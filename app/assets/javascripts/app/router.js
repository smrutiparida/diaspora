app.Router = Backbone.Router.extend({
  routes: {
    //new hotness
    "posts/:id": "singlePost",
    "posts/:id/next": "siblingPost",
    "posts/:id/previous": "siblingPost",
    "p/:id": "singlePost",

    //oldness
    "activity": "stream",
    "stream": "stream",
    "participate": "stream",
    "explore": "stream",
    "aspects": "aspects",
    "aspects/stream": "aspects_stream",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "followed_tags": "followed_tags",
    "tags/:name": "followed_tags",
    "people/:id/photos": "photos",

    "people/:id": "stream",
    "u/:name": "stream"
  },

  singlePost : function(id) {
    this.renderPage(function(){ return new app.pages.SinglePostViewer({ id: id })});
  },

  siblingPost : function(){ //next or previous
    var post = new app.models.Post();
    post.bind("change", setPreloadAttributesAndNavigate)
    post.fetch({url : window.location})

    function setPreloadAttributesAndNavigate(){
      window.gon.preloads.post = post.attributes
      app.router.navigate(post.url(), {trigger:true, replace: true})
    }
  },

  renderPage : function(pageConstructor){
    app.page && app.page.unbind && app.page.unbind() //old page might mutate global events $(document).keypress, so unbind before creating
    app.page = pageConstructor() //create new page after the world is clean (like that will ever happen)
    $("#container").html(app.page.render().el)
  },

  //below here is oldness

  stream : function(page) {    
    app.stream = new app.models.Stream();
    app.stream.fetch();
    app.page = new app.views.Stream({model : app.stream});
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.items});

    $("#main_stream").html(app.page.render().el);
    $('#selected_aspect_contacts .content').html(streamFacesView.render().el);
    this.hideInactiveStreamLists();
  },

  photos : function() {
    app.photos = new app.models.Stream([], {collection: app.collections.Photos});
    app.page = new app.views.Photos({model : app.photos});
    $("#main_stream").html(app.page.render().el);
  },

  followed_tags : function(name) {
    
    this.stream();
    
    //app.tagFollowings = new app.collections.TagFollowings();
    //this.followedTagsView = new app.views.TagFollowingList({collection: app.tagFollowings});
    //$("#tags_list").replaceWith(this.followedTagsView.render().el);
    //this.followedTagsView.setupAutoSuggest();

    //app.tagFollowings.reset(gon.preloads.tagFollowings);

    //if(name) {
    //  var followedTagsAction = new app.views.TagFollowingAction(
    //        {tagText: decodeURIComponent(name).toLowerCase()}
    //      );
    //  $("#author_info").prepend(followedTagsAction.render().el)
    //}
    this.hideInactiveStreamLists();
  },

  aspects : function(){
    app.aspects = new app.collections.Aspects(app.currentUser.get('aspects'));
    this.aspects_list =  new app.views.AspectsList({ collection: app.aspects });
    this.aspects_list.render();
    app.aspectContentId = "all";
    this.aspects_stream();
    this.update_sessions();
  },

  aspects_stream : function(){    
    var ids = app.aspects.selectedAspects('id');

    app.teacherModel = new app.models.Teacher
    app.teacherModel.get_teacher(ids);

    app.reportModel = new app.models.Report
    app.reportModel.get_report(ids);

    if(ids.length > 0){
      $('#download_link').attr("href", "/user/faq?a_id=" + ids[0])
      $('#download_grade_link').attr("href", "/reports/download?a_id=" + ids[0])
      $('#course_invite_link').attr("href", "/users/invitations?aspect=" + ids[0])
    }
    
    app.stream = new app.models.StreamAspects([], { aspects_ids: ids});
    app.stream.fetch();

    app.page = new app.views.Stream({model : app.stream});
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.items});
    app.publisher.setSelectedAspects(ids);

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.items});

    $("#main_stream").html(app.page.render().el);
    $('#selected_aspect_contacts .content').html(streamFacesView.render().el);

    this.hideInactiveStreamLists();
  },
  
  update_sessions:function(){
    var ids = app.aspects.selectedAspects('id');
    //$('#session-button').attr('href', '/contents/new?a_id=' + ids[0]);
    $("#sessions_list").remove();
    $('.all_aspects').find('.icons-check_yes_ok.selected').siblings(":last").after("<ul id='sessions_list' class='content' style='display:none;'></ul>");
    var sessionsView = new app.models.Sessions;
    if(ids.length > 0){
      sessionsView.getSessions(ids);  
    }
    
  },

  hideInactiveStreamLists: function() {
    if(this.aspects_list && Backbone.history.fragment != "aspects")
      this.aspects_list.hideAspectsList();

    if(this.followedTagsView && Backbone.history.fragment != "followed_tags")
      this.followedTagsView.hideFollowedTags();
  },
});