Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash)
});

Handlebars.registerHelper('imageUrl', function(path){
  return app.baseImageUrl() + path;
});

Handlebars.registerHelper('linkToPerson', function(context, block) {
  var html = "<a href=\"/people/" + context.guid + "\" class=\"author-name ";
      html += Handlebars.helpers.hovercardable(context);
      html += "\">";
      html += block.fn(context);
      html += "</a>";

  return html
});


// allow hovercards for users that are not the current user.
// returns the html class name used to trigger hovercards.
Handlebars.registerHelper('hovercardable', function(person) {
  if( app.currentUser.get('guid') != person.guid ) {
    return 'hovercardable';
  }
  return '';
});

Handlebars.registerHelper('personImage', function(person, size, imageClass) {
  /* we return here if person.avatar is blank, because this happens when a
   * user is unauthenticated.  we don't know why this happens... */
  if( _.isUndefined(person.avatar) ) { return }

  size = ( !_.isString(size) ) ? "small" : size;
  imageClass = ( !_.isString(imageClass) ) ? size : imageClass;

  return _.template('<img src="<%= src %>" class="avatar <%= img_class %>" title="<%= title %>" />', {
    'src': person.avatar[size],
    'img_class': imageClass,
    'title': _.escape(person.name)
  });
});

Handlebars.registerHelper('localTime', function(timestamp) {
  return new Date(timestamp).toLocaleString();
});



Handlebars.registerHelper('anonymityString', function(author, type) {
  /* we return here if person.avatar is blank, because this happens when a
   * user is unauthenticated.  we don't know why this happens... */
  if( _.isUndefined(author.person) ) { return }

  var htmlStr = author.name;
  var class_name = "plain";

  if(type == "img"){
    class_name = "img";
    htmlStr = Handlebars.helpers['personImage'].call(this);
  }  
  
  if(author.name == "Anonymous"){
    
    return _.template('<span class="<%= class_name %>"> <%= htmlStr %> </span>');   
  }
  else {
    htmlStr = Handlebars.helpers['personImage'].call(this);
    hoverStr = Handlebars.helpers['hovercardable'].call(this);
    return _.template('<a href="/people/<%= author.guid %>" class="<%= class_name %> <%= hoverStr %>"> <%= htmlStr %></a>');  
  }
});