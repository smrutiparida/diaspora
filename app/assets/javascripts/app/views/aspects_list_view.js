app.views.AspectsList = app.views.Base.extend({
  templateName: 'aspects-list',

  el: '#aspects_list',

  events: {
    'click .toggle_selector' : 'toggleAll'
  },

  initialize: function() {
    this.collection.on('change', this.toggleSelector, this);
    this.collection.on('change', this.updateStreamTitle, this);
  },

  postRenderTemplate: function() {
    total_courses = 0
    this.collection.each(this.appendAspect, this);
    if(total_courses == 0)
    {
       $("#aspects_list > *:last").before('<li><div class="icons-check_yes_ok"></div><span>No Courses</span></li>');
    }
    this.$('a[rel*=facebox]').facebox();
    if(app.currentUser.get('role') != "teacher"){
      $('#aspects_list .modify_aspect').hide(); 
      //$('#teacher-create-course').hide(); 
    }
    //else {
    //  
      
    //  $('#student-join-course').hide();
    //}

    this.updateStreamTitle();
    this.toggleSelector();
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      IsUserTeacher: this.IsUserTeacher()
    })
  },

  IsUserTeacher:function(){
    return app.currentUser.get('role') == "teacher" || app.currentUser.get('role') == "institute_admin";
  },

  appendAspect: function(aspect) {
    //alert(aspect.folder);    
    if(aspect.get('folder') && aspect.get('folder') == "Classroom"){
      $("#aspects_list > *:last").before(new app.views.Aspect({
        model: aspect, attributes: {'data-aspect_id': aspect.get('id')}
      }).render().el);  
      total_courses += 1;
    }
    else
    {
      $("#personal_aspects_list > *:last").before(new app.views.Aspect({
        model: aspect, attributes: {'data-aspect_id': aspect.get('id')}
      }).render().el);  
    }
    
  },

  toggleAll: function(evt) {
    if (evt) { evt.preventDefault(); };

    var aspects = this.$('li:not(:last)')
    if (this.collection.allSelected()) {
      this.collection.deselectAll();
      aspects.each(function(i){
        $(this).find('.icons-check_yes_ok').removeClass('selected');
      });
    } else {
      console.log("selecting all aspects");
      this.collection.selectAll();
      aspects.each(function(i){
        $(this).find('.icons-check_yes_ok').addClass('selected');
      });
    }

    this.toggleSelector();
    app.router.aspects_stream();
  },

  toggleSelector: function() {
    var selector = this.$('a.toggle_selector');
    if (this.collection.allSelected()) {
      selector.text(Diaspora.I18n.t('aspect_navigation.deselect_all'));
    } else {
      selector.text(Diaspora.I18n.t('aspect_navigation.select_all'));
    }
  },

  updateStreamTitle: function() {
    $('.stream_title').text(this.collection.toSentence());
  },

  hideAspectsList: function() {
    this.$el.empty();
  },
})
