module NotificationMailers
  class CourseCreateEmail < NotificationMailers::Base
  	attr_accessor :aspect
    delegate :name, to: :aspect, prefix: true
    delegate :code, to: :aspect, prefix: true

    def set_headers(aspect_id)
      @aspect = Aspect.find(aspect_id)

      @headers[:to] = name_and_address(@recipient.first_name, @recipient.email)
      @headers[:subject] = "Congratulations! You have successfully created your course on LMNOP"
    end
  end
end