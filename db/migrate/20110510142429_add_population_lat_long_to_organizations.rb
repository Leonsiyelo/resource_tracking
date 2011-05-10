class AddPopulationLatLongToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :latitude, :decimal
    add_column :organizations, :longitude, :decimal
    add_column :organizations, :catchment_population, :decimal
    add_column :organizations, :facility_type, :string
  end

  def self.down
    remove_column :organizations, :latitude
    remove_column :organizations, :longitude
    remove_column :organizations, :catchment_population
    remove_column :organizations, :facility_type
  end
end
