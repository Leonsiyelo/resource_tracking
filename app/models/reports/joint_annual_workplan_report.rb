require 'fastercsv'

class Reports::JointAnnualWorkplanReport
  include Reports::Helpers

  def initialize(current_user)
    @activities = Activity.only_simple.canonical_with_scope.find(:all,
      #:conditions => ["activities.id IN (?)", [4498, 4499]], # TODO: remove this
      :include => [:locations, :provider, :organizations,
        :beneficiaries, {:data_response => :responding_organization}])

    hc_sub_activities = Activity.with_type('SubActivity').
                          implemented_by_health_centers.find(:all,
                            :select => 'activity_id, COUNT(*) AS total',
                            :group => 'activity_id')

    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities.each do |activity|
        hc_sub_activities_count = hc_sub_activities.detect{|sa| sa.activity_id == activity.id}.try(:total) || 0
        build_rows(csv, activity, hc_sub_activities_count)
      end
    end
  end

  def csv
    @csv_string
  end

  private

  def build_rows(csv, activity, hc_sub_activity_count)
    row = []
    row << "#{activity.name} - #{activity.description}"
    row << activity.budget_q1
    row << activity.budget_q2
    row << activity.budget_q3
    row << activity.budget_q4
    row << activity.locations.map(&:short_display).join(' | ')
    row << activity.sub_activities_count
    row << activity.data_response.responding_organization.try(:name)
    row << activity.provider.try(:name) || "No Implementer Specified"
    row << activity.organizations.map(&:name).join(' | ')
    row << hc_sub_activity_count
    row << activity.beneficiaries.map(&:short_display).join(' | ')
    row << activity.id
    row << activity.currency
    row << activity.budget
    row << Money.new(activity.budget.to_i * 100, get_currency(activity)) .exchange_to(:USD)
    row << (activity.budget_district_coding.empty? ? 'yes' : 'no')

    build_code_assignment_rows(csv, activity, row.dup)
  end

  private

    def build_code_assignment_rows(csv, activity, base_row)
      activity.budget_cost_category_coding.each do |cost_category_coding|
        activity.budget_district_coding.each do |district_coding|
          activity.budget_coding.each do |ca|
            row = base_row.dup
            #amount = "#{ca.cached_amount} * #{get_district_ratio(activity, district_coding)} * #{get_cost_category_ratio(activity, cost_category_coding)}" # FOR DEBUG ONLY
            amount = ca.cached_amount * get_district_ratio(activity, district_coding) * get_cost_category_ratio(activity, cost_category_coding)
            row << amount
            row << Money.new((amount * 100).to_i, activity.currency.to_sym).exchange_to(:USD)
            row << nil
            row << ca.code.try(:short_display)
            row << district_coding.code.try(:short_display)
            row << cost_category_coding.code.try(:short_display)
            csv << row
          end
        end
      end
    end

    def header()
      row = []
      row << "Activity Description"
      row << "Q1"
      row << "Q2"
      row << "Q3"
      row << "Q4"
      row << "Districts"
      row << "Sub-implementers"
      row << "Data Source"
      row << "Implementer"
      row << "Institutions Assisted"
      row << "# of HC's Sub-implementing"
      row << "Beneficiaries"
      row << "ID"
      row << "Currency"
      row << "Total Budget"
      row << "Converted Budget (USD)"
      row << "National?"
      row << "Classified Budget"
      row << "Converted Classified Budget (USD)"
      row << "HSSPII"
      row << "Code"
      row << "District"
      row << "Cost Category"
      row
    end

    def get_district_ratio(activity, district_coding)
      activity.budget && activity.budget > 0 ?
        district_coding.cached_amount / activity.budget : 0
    end

    def get_cost_category_ratio(activity, cost_category_coding)
      activity.budget && activity.budget > 0 ?
        cost_category_coding.cached_amount / activity.budget : 0
    end

    def get_currency(activity)
      activity.currency.blank? ? :USD : activity.currency.to_sym
    end
end
