# Expected format

puts "Loading facility details..."

# Organization.delete_all
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's
$id_col            = 0
$lat     = 11
$long         = 12
$fac_type     = 13
$pop      = 14

i = 0
FasterCSV.foreach("db/fixes/facility_details.csv", :headers => true ) do |row|
  i = i + 1
  fosaid = row[$id_col]
  lat = row[$lat]
  long     = row[$long]
  fac_type = row[$fac_type]
  pop  = row[$pop]
  org = Organization.find_by_fosaid fosaid
  puts "error on row #{i} - did not find org with id #{fosaid}" unless org

  if org
    org.latitude = lat
    org.longitude = long
    org.facility_type = fac_type
    org.catchment_population = pop
    puts "Updating org #{org.name}" if org.save
  end

end

