class SeedFacilityInfo < ActiveRecord::Migration
  def self.up
    #load 'db/fixes/facility_details.rb' if ["production", "staging", "development"].include?(RAILS_ENV)
  end

  def self.down
    puts "irreversible, already loaded facility info"
  end
end
