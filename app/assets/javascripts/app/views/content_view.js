app.views.Content = app.views.Base.extend({
  events: {
    "click .expander": "expandPost"
  },

  presenter : function(){
    //alert("app.views.Content:Presenter");
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(this.model.get("text"), this.model),
      largePhoto : this.largePhoto(),
      smallPhotos : this.smallPhotos(),
      location: this.location(),
      documents: this.documents(),
      assignments: this.assignments(),
      quiz : this.quiz()
    });
  },


  largePhoto : function() {
    //alert("app.views.Content:largePhoto");
    var photos = this.model.get("photos")
    if(!photos || photos.length == 0) { return }
    return photos[0]
  },

  smallPhotos : function() {
    //alert("app.views.Content:Presenter:smallPhotos");
    var photos = this.model.get("photos")
    if(!photos || photos.length < 2) { return }
    return photos.slice(1,8)
  },

  documents : function() {
    //alert("app.views.Content:Presenter:documents");
    var documents = this.model.get("documents")    
    if(!documents) { return }    
    //alert(documents[0].icon);  
    return documents;
  },

  assignments : function() {
    //alert("app.views.Content:Presenter:documents");
    var assignments = this.model.get("assignments")    
    if(!assignments) { return }    
    //alert(documents[0].icon);  
    return assignments;
  },

  quiz : function() {
    //alert("app.views.Content:Presenter:documents");
    var quizzes = this.model.get("quiz_assignments")    
    if(!quizzes || quizzes.length == 0) { return }    
    //alert(quizzes[0].icon);  
    return quizzes[0];
  },


  expandPost: function(evt) {
    //alert("app.views.Content:Presenter:expandPost");
    var el = $(this.el).find('.collapsible');
    el.removeClass('collapsed').addClass('opened');
    el.animate({'height':el.data('orig-height')}, 550, function() {
      el.css('height','auto');
    });
    $(evt.currentTarget).hide();
  },

  location: function(){
    //alert("app.views.Content:Presenter:location");
    var address = this.model.get('address')? this.model.get('address') : '';
    return address;
  },

  collapseOversized : function() {
    //alert("app.views.Content:Presenter:collapseOversized");
    var collHeight = 200
      , elem = this.$(".collapsible")
      , oembed = elem.find(".oembed")
      , opengraph = elem.find(".opengraph")
      , addHeight = 0;
    if($.trim(oembed.html()) != "") {
      addHeight += oembed.height();
    }
    if($.trim(opengraph.html()) != "") {
      addHeight += opengraph.height();
    }

    // only collapse if height exceeds collHeight+20%
    if( elem.height() > ((collHeight*1.2)+addHeight) && !elem.is(".opened") ) {
      elem.data("orig-height", elem.height() );
      elem
        .height( Math.max(collHeight, addHeight) )
        .addClass("collapsed")
        .append(
        $('<div />')
          .addClass('expander')
          .text( Diaspora.I18n.t("show_more") )
      );
    }
  },

  postRenderTemplate : function(){
    //alert("app.views.Content:Presenter:postRenderTemplate");
    _.defer(_.bind(this.collapseOversized, this))
  }
});

app.views.StatusMessage = app.views.Content.extend({
  templateName : "status-message",
  postRenderTemplate : function(){
    if (app.currentUser.get('role') == "teacher"){
      $('.submit-course-module').attr('style', 'display:none;');
    }
  }
});

app.views.ExpandedStatusMessage = app.views.StatusMessage.extend({
  postRenderTemplate : function(){
  }
});

app.views.Reshare = app.views.Content.extend({
  templateName : "reshare"
});

app.views.OEmbed = app.views.Base.extend({
  templateName : "oembed",
  events : {
    "click .thumb": "showOembedContent"
  },

  presenter:function () {
    o_embed_cache = this.model.get("o_embed_cache")
    if(o_embed_cache) {
      typemodel = { rich: false, photo: false, video: false, link: false }
      typemodel[o_embed_cache.data.type] = true
      o_embed_cache.data.types = typemodel
    }
    return _.extend(this.defaultPresenter(), {
      o_embed_html : app.helpers.oEmbed.html(o_embed_cache)
    })
  },

  showOembedContent : function (evt) {
    if( $(evt.target).is('a') ) return;
    var insertHTML = $(app.helpers.oEmbed.html(this.model.get("o_embed_cache")));
    var paramSeparator = ( /\?/.test(insertHTML.attr("src")) ) ? "&" : "?";
    insertHTML.attr("src", insertHTML.attr("src") + paramSeparator + "autoplay=1&wmode=opaque");
    this.$el.html(insertHTML);
  }
});

app.views.OpenGraph = app.views.Base.extend({
  templateName : "opengraph"
});