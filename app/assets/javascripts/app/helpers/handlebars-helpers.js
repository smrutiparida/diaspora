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



Handlebars.registerHelper('anonymityString', function(author, type, make_anonymous) {
  /* we return here if person.avatar is blank, because this happens when a
   * user is unauthenticated.  we don't know why this happens... */

  if( _.isUndefined(author) ) { return }

  var htmlStr = make_anonymous == "true" ? "Anonymous" : author.name;
  var class_name = "plain";

  if (type == "img"){
    htmlStr = make_anonymous == "false" ? Handlebars.helpers['personImage'].call(this, author) : _.template('<img src="/assets/user/default.png" class="avatar small" title="Anonymous" />',{});
    class_name = "img";
  } 

  if(make_anonymous == "true"){
    console.log("step 3"); 
    return _.template('<span class="<%= class_name %>"> <%= htmlStr %> </span>', {
      'class_name': class_name,
      'htmlStr': htmlStr
    });
  }
  else {
    console.log("step 4");
  
    hoverStr = Handlebars.helpers['hovercardable'].call(this, author);
    return _.template('<a href="/people/<%= guid %>" class="<%= class_name %> <%= hoverStr %>"> <%= htmlStr %></a>', {
      'guid': author.guid,
      'class_name': class_name,
      'htmlStr': htmlStr,
      'hoverStr': hoverStr
    });  
  }
});