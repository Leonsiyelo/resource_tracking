print "\nloading data requests"

DataRequest.find_or_create_by_organization_id(
  Organization.find_or_create_by_name("Ministry of Health"),
  :title => "FY2010 Workplan and FY2009 Expenditures",
  :due_date => Date.new(2010, 9, 1))

print "\n...loading data requests DONE"


