require 'sidekiq'

class SkWorker
  include Sidekiq::Worker

  def perform()
    # The guts of the job to perform go here
    puts "Scheduled job executed at #{Time.now}"
  end

  def self.schedule_next
    # Schedule the next execution every 24 hours
    24 * 60 * 60 # 24 hours in seconds
  end
end