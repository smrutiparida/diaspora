app.views.Base = Backbone.View.extend({

  initialize : function(options) {
    alert("app.views.Base:initialize");
    this.setupRenderEvents();
  },

  presenter : function(){
    alert("app.views.Base:presenter");
    return this.defaultPresenter()
  },

  setupRenderEvents : function(){
    alert("app.views.Base:setupRenderEvents");
    if(this.model) {
      //this should be in streamobjects view
      this.model.bind('remove', this.remove, this);
    }

    // this line is too generic.  we usually only want to re-render on
    // feedback changes as the post content, author, and time do not change.
    //
    // this.model.bind('change', this.render, this);
  },

  defaultPresenter : function(){
    alert("app.views.Base:defaultPresenter");
    var modelJson = this.model && this.model.attributes ? _.clone(this.model.attributes) : {}

    return _.extend(modelJson, {
      current_user : app.currentUser.attributes,
      loggedIn : app.currentUser.authenticated()
    });
  },

  render : function() {
    alert("app.views.Base:render");
    this.renderTemplate()
    this.renderSubviews()
    this.renderPluginWidgets()
    this.removeTooltips()

    return this
  },

  renderTemplate : function(){
    alert("app.views.Base:renderTemplate");
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter
    this.template = JST[this.templateName+"_tpl"]
    if(!this.template) {
      console.log(this.templateName ? ("no template for " + this.templateName) : "no templateName specified")
    }
    alert(this.templateName);  
    this.$el
      .html(this.template(presenter))
      .attr("data-template", _.last(this.templateName.split("/")));
    alert(this.$el.html());  
    this.postRenderTemplate();
    alert("Exit:app.views.Base:renderTemplate");
  },

  postRenderTemplate : $.noop, //hella callbax yo

  renderSubviews : function(){
    alert("app.views.Base:renderSubviews");
    var self = this;
    _.each(this.subviews, function(property, selector){
      var view = _.isFunction(self[property]) ? self[property]() : self[property]
      if(view) {
        self.$(selector).html(view.render().el)
        view.delegateEvents();
      }
    })
  },

  renderPluginWidgets : function() {
    alert("app.views.Base:renderPluginWidgets");
    this.$(this.tooltipSelector).tooltip();
    this.$("time").timeago();
  },

  removeTooltips : function() {
    $(".tooltip").remove();
  },

  setFormAttrs : function(){
    this.model.set(_.inject(this.formAttrs, _.bind(setValueFromField, this), {}))

    function setValueFromField(memo, attribute, selector){
      if(attribute.slice("-2") === "[]") {
        memo[attribute.slice(0, attribute.length - 2)] = _.pluck(this.$el.find(selector).serializeArray(), "value")
      } else {
        memo[attribute] = this.$el.find(selector).val() || this.$el.find(selector).text();
      }
      return memo
    }
  },

  destroyModel: function(evt) {
    evt && evt.preventDefault();
    if (confirm(Diaspora.I18n.t("confirm_dialog"))) {
      this.model.destroy();
      this.remove();
    }
  }
});

