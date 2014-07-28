# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :environment, "development"

# Example:
set :output, File.join( File.dirname( __FILE__ ), '..', 'log', 'scheduled_tasks.log' )

#every 1.day, :at => '9:00 am' do
#  runner "MyModel.some_method"
#end

every 1.day, :at => '12:45 pm' do
  runner Workers::UpdateReportScore.perform()
end

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
