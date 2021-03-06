Factory.define :project, :class => Project do |f|
  f.name                { 'project_name' }
  f.description         { 'project_description' }
  f.budget              { 20000000.00 }
  f.start_date          { Date.parse("2010-01-01") }
  f.end_date            { Date.parse("2010-12-31") }
  f.data_response       { Factory(:data_response) }
end
