# check for production environment

def log(message)
  Rails.logger.info message
  puts message
end

def update_report(t)
  start_time = Time.now
  key = t.name_with_args.gsub(/reports:/, '')
  log "#{start_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE BEGIN: #{key}"
  report     = Report.find_or_initialize_by_key(key)
  report.save # regenerates csv
  end_time = Time.now
  log "#{end_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE END: #{key} (Elapsed: #{(end_time - start_time).round(2)}s)"
end

namespace :reports do
  desc "Saves 'districts_by_nsp_budget' report to database"
  task :districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'districts_by_all_codes_budget' report to database"
  task :districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'users_by_organization' report to database"
  task :users_by_organization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_partner_budget' report to database"
  task :map_districts_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_partner_spent' report to database"
  task :map_districts_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_nsp_budget' report to database"
  task :map_districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_all_codes_budget' report to database"
  task :map_districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_facilities_by_partner_budget' report to database"
  task :map_facilities_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_facilities_by_partner_spent' report to database"
  task :map_facilities_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_summary' report to database"
  task :activities_summary => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_district' report to database"
  task :activities_by_district => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_one_row_per_district' report to database"
  task :activities_one_row_per_district => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_coding' report to database"
  task :activities_by_budget_coding => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_cost_categorization' report to database"
  task :activities_by_budget_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_districts' report to database"
  task :activities_by_budget_districts => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_coding' report to database"
  task :activities_by_expenditure_coding => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_cost_categorization' report to database"
  task :activities_by_expenditure_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_districts' report to database"
  task :activities_by_expenditure_districts => :environment do |t|
    update_report(t)
  end

  desc "Saves 'jawp_report_budget' report to database"
  task :jawp_report_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'jawp_report_spent' report to database"
  task :jawp_report_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_nsp_budget' report to database"
  task :activities_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_nha' report to database"
  task :activities_by_nha => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_all_codes_budget' report to database"
  task :activities_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves all reports to database"
  task :all => [
    'districts_by_nsp_budget',
    'districts_by_all_codes_budget',
    'users_by_organization',
    'map_districts_by_partner_budget',
    'map_districts_by_partner_spent',
    'map_districts_by_nsp_budget',
    'map_districts_by_all_codes_budget',
    'map_facilities_by_partner_budget',
    'map_facilities_by_partner_spent',
    'activities_summary',
    'activities_by_district',
    'activities_one_row_per_district',
    'activities_by_budget_coding',
    'activities_by_budget_cost_categorization',
    'activities_by_budget_districts',
    'activities_by_expenditure_coding',
    'activities_by_expenditure_cost_categorization',
    'activities_by_expenditure_districts',
    'jawp_report_budget',
    'jawp_report_spent',
    'activities_by_nsp_budget',
    'activities_by_nha',
    'activities_by_all_codes_budget'
  ]
end
