# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :environment, "development"

# Example:
set :output, File.join( File.dirname( __FILE__ ), '..', 'log', 'scheduled_tasks.log' )

every 1.day, :at => '3:32 pm' do
  runner "User.digest_mail"
end

every 1.day, :at => '1:15 pm' do
  runner "Report.update_report_score"
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
