
// Uploader view for the publisher.
// Initializes the file uploader plugin and handles callbacks for the upload
// progress. Attaches previews of finished uploads to the publisher.

app.views.DocumentUploader = Backbone.View.extend({

  allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'ppts'],
  sizeLimit: 4194304,  // bytes

  initialize: function() {
    this.uploader = new qq.FileUploaderBasic({
      element: this.el,
      button:  this.el,

      //debug: true,

      action: '/documents',
      params: { document: { pending: false }},
      allowedExtensions: this.allowedExtensions,
      sizeLimit: this.sizeLimit,
      messages: {
        typeError:  Diaspora.I18n.t('document_uploader.invalid_ext'),
        sizeError:  Diaspora.I18n.t('document_uploader.size_error'),
        emptyError: Diaspora.I18n.t('document_uploader.empty')
      },
      onProgress: _.bind(this.progressHandler, this),
      onSubmit:   _.bind(this.submitHandler, this),
      onComplete: _.bind(this.uploadCompleteHandler, this)

    });

    this.el_info = $('<div id="documentInfo" />');
    this.options.publisher.el_wrapper.before(this.el_info);

    this.options.publisher.el_documentzone.on('click', '.x', _.bind(this._removeDocument, this));
  },

  progressHandler: function(id, fileName, loaded, total) {
    var progress = Math.round(loaded / total * 100);
    this.el_info.text(fileName + ' ' + progress + '%').fadeTo(200, 1);
  },

  submitHandler: function(id, fileName) {
    this.$el.addClass('loading');
    this._addDocumentPlaceholder();
  },

  // add photo placeholders to the publisher to indicate an upload in progress
  _addDocumentPlaceholder: function() {
    var publisher = this.options.publisher;
    publisher.setButtonsEnabled(false);

    publisher.el_wrapper.addClass('with_attachments');
    publisher.el_documentzone.append(
      '<li class="publisher_document loading" style="position:relative;">' +
      '  <img src="'+Handlebars.helpers.imageUrl('ajax-loader2.gif')+'" alt="" />'+
      '</li>'
    );
  },

  uploadCompleteHandler: function(id, fileName, response) {
    this.el_info.text(Diaspora.I18n.t('document_uploader.completed', {file: fileName})).fadeTo(2000, 0);

    
    var id  = response.data.document.id,
        url = response.data.document.unprocessed_doc.url;

    this._addFinishedDocument(id, url);
    this.trigger('change');
  },

  // replace the first photo placeholder with the finished uploaded image and
  // add the id to the publishers form
  _addFinishedDocument: function(id, url) {
    var publisher = this.options.publisher;

    // add form input element
    publisher.$('.content_creation form').append(
      '<input type="hidden", value="'+id+'" name="documents[]" />'
    );

    // replace placeholder
    var placeholder = publisher.el_documentzone.find('li.loading').first();
    placeholder
      .removeClass('loading')
      .append(
        '<div class="x">X</div>'+
        '<div class="circle"></div>'
       )
      .find('img').attr({'src': '/apple-touch-icon.png', 'data-id': id});

    // no more placeholders? enable buttons
    if( publisher.el_documentzone.find('li.loading').length == 0 ) {
      this.$el.removeClass('loading');
      publisher.setButtonsEnabled(true);
    }
  },

  // remove an already uploaded photo
  _removeDocument: function(evt) {
    var self  = this;
    var photo = $(evt.target).parents('.publisher_photo')
    var img   = photo.find('img');

    document.addClass('dim');
    $.ajax({
      url: '/documents/'+img.attr('data-id'),
      dataType: 'json',
      type: 'DELETE',
      success: function() {
        $.when(photo.fadeOut(400)).then(function(){
          photo.remove();

          if( self.options.publisher.$('.publisher_photo').length == 0 ) {
            // no more photos left...
            self.options.publisher.el_wrapper.removeClass('with_attachments');
          }

          self.trigger('change');
        });
      }
    });

    return false;
  }

});
