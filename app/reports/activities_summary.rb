require 'fastercsv'

class Reports::ActivitiesSummary
  include Reports::Helpers

  def initialize
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header

      #
      # NOTE: can't eager load :projects association because
      # sub_activity delegates it to activity and there is some problem
      #
      #Activity.find(:all, :conditions => ['id IN (?)', [4760]]).each do |activity| # DEBUG ONLY
      #Activity.find(:all, :conditions => ['id IN (?)', [1416]]).each do |activity| # DEBUG ONLY
      Activity.find(:all, :include => :provider).each do |activity|
        if ((activity.class == Activity && activity.sub_activities.empty?) ||
            activity.class == SubActivity)
          csv << build_row(activity)
        end
      end
    end
  end

  private

    def build_header
      row = []

      row << "funding_source"
      row << "project"
      row << "org.name"
      row << "org.type"
      row << "activity.id"
      row << "activity.name"
      row << "activity.description"
      row << "activity.budget"
      row << "activity.spend"
      row << "currency"
      row << "activity.start_date"
      row << "activity.end_date"
      row << "activity.provider"
      row << "activity.provider.FOSAID"
      row << "Facility?"
      row << "Latitude" 
      row << "Longitude" 
      row << "Facility Type" 
      row << "Catchment Population" 
      row << "activity.text_for_beneficiaries"
      row << "activity.text_for_targets"
      row << "Is Sub Activity?"
      row << "parent_activity.total_budget"
      row << "parent_activity.total_spend"

      row
    end

    def build_row(activity)
      organization  = activity.data_response.organization
      #TODO handle sub activities correctly

      row = []

      row << funding_source_name(activity)
      row << activity.project.try(:name)
      row << "#{h organization.name}"
      row << "#{organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      row << "#{activity.budget_in_usd}"
      row << "#{activity.spend_in_usd}"
      row << "#{activity.currency}"
      row << "#{activity.start_date}"
      row << "#{activity.end_date}"
      row << provider_name(activity)
      row << provider_fosaid(activity)
      provider = activity.provider
              unless provider.nil? or !provider.service_provider?
                row << provider.service_provider?
                row <<    provider.latitude 
                row <<    provider.longitude 
                row <<    provider.facility_type 
                row <<    provider.catchment_population 
              else
                row << "FALSE"
                row <<  ""
                row <<    ""
                row <<    ""
                row <<    "" 
              end
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << is_activity(activity)
      row << parent_activity_budget(activity)
      row << parent_activity_spend(activity)

      row
    end

end
