require 'fastercsv'

class Reports::JawpReport
  include Reports::Helpers

  def initialize(type, activities)
    @is_budget         = is_budget?(type)

    @activities = activities
#Activity.only_simple.find(:all,
                   #:conditions => ["activities.id IN (?)", [1918]], # NOTE: FOR DEBUG ONLY
                   #:conditions => ["activities.id IN (?)", [4498, 4499]], # NOTE: FOR DEBUG ONLY

#                   :include => [:locations, :provider, :organizations,

#                                :beneficiaries, {:data_response => :organization}])

    @hc_sub_activities = Activity.with_type('SubActivity').
      implemented_by_health_centers.find(:all,
                                         :select => 'activity_id, COUNT(*) AS total',
                                         :group => 'activity_id')
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @activities.each{|activity| build_rows(csv, activity)}
    end
  end

  private

  # gor_quarters methods returns values for US fiscal year (10th month)
  # otherwise it returns the values for Rwanda fiscal year
  def build_rows(csv, activity)
    if @is_budget
      amount_q1             = activity.budget_gor_quarter(1)
      amount_q2             = activity.budget_gor_quarter(2)
      amount_q3             = activity.budget_gor_quarter(3)
      amount_q4             = activity.budget_gor_quarter(4)
      amount_total          = activity.budget
      is_national           = (activity.budget_district_coding.empty? ? 'yes' : 'no')
    else
      amount_q1             = activity.spend_gor_quarter(1)
      amount_q2             = activity.spend_gor_quarter(2)
      amount_q3             = activity.spend_gor_quarter(3)
      amount_q4             = activity.spend_gor_quarter(4)
      amount_total          = activity.spend
      is_national           = (activity.spend_district_coding.empty? ? 'yes' : 'no')
    end

    row = []
    row << activity.name
    row << activity.description
    row << amount_q1
    row << amount_q2
    row << amount_q3
    row << amount_q4
    row << get_locations(activity)
    row << activity.sub_activities_count
    row << get_hc_sub_activity_count(activity)
    row << get_sub_implementers(activity)
    row << activity.organization.try(:name)
    row << activity.provider.try(:name) || "No Implementer Specified"
    row << get_institutions_assisted(activity)
    row << get_beneficiaries(activity)
    row << activity.id
    row << activity.currency
    row << amount_total
    row << Money.new(amount_total.to_i * 100, get_currency(activity)) .exchange_to(:USD)
    row << is_national
    row << Activity.only_simple.canonical_with_scope.find(:first, :conditions => {:id => activity.id}).nil?

    build_code_assignment_rows(csv, row, activity, amount_total)
  end

  private

    def build_code_assignment_rows(csv, base_row, activity, amount_total)
      if @is_budget
        codings               = fake_one_assignment_if_none(amount_total, activity.budget_coding)
        district_codings      = fake_one_assignment_if_none(amount_total, activity.budget_district_coding)
        cost_category_codings = fake_one_assignment_if_none(amount_total, activity.budget_cost_category_coding)
      else
        codings               = fake_one_assignment_if_none(amount_total, activity.spend_coding)
        district_codings      = fake_one_assignment_if_none(amount_total, activity.spend_district_coding)
        cost_category_codings = fake_one_assignment_if_none(amount_total, activity.spend_cost_category_coding)
      end
      funding_sources       = fake_one_funding_source_if_none(get_funding_sources(activity))
      funding_sources_total = get_funding_sources_total(funding_sources, @is_budget)

      coding_with_parent_codes = get_coding_with_parent_codes(codings)
      cost_category_coding_with_parent_codes = get_coding_with_parent_codes(cost_category_codings)

      cost_category_coding_with_parent_codes.each do |cost_category_ca_coding|
        cost_category_coding = cost_category_ca_coding[0]
        cost_category_codes  = cost_category_ca_coding[1]

        funding_sources.each do |funding_source|
          district_codings.each do |district_coding|
            coding_with_parent_codes.each do |ca_codes|
              ca                    = ca_codes[0]
              codes                 = ca_codes[1]
              last_code             = codes.last
              row                   = base_row.dup
              funding_source_amount = get_funding_source_amount(funding_source, @is_budget)
              amount                = (amount_total || 0) *
                get_ratio(amount_total, ca.cached_amount) *
                get_ratio(amount_total, district_coding.cached_amount) *
                get_ratio(amount_total, cost_category_coding.cached_amount) *
                get_ratio(funding_sources_total, funding_source_amount)

              #puts "  get_ratio(amount_total, ca.cached_amount) *" + get_ratio(amount_total, ca.cached_amount).to_s

              #puts "  get_ratio(amount_total, district_coding.cached_amount) *" + get_ratio(amount_total, district_coding.cached_amount).to_s

              #puts "  get_ratio(amount_total, cost_category_coding.cached_amount) *" + get_ratio(amount_total, cost_category_coding.cached_amount).to_s

              #puts "  get_ratio(funding_sources_total, funding_source_amount)" + get_ratio(funding_sources_total, funding_source_amount).to_s

              row << funding_source.from.try(:name)
              row << funding_source.from.try(:type)
              row << amount
              row << get_percentage(amount_total, amount)
              row << Money.new((amount * 100).to_i, get_currency(activity)).exchange_to(:USD)
              row << codes_cache[ca.code_id].try(:hssp2_stratobj_val)
              row << codes_cache[ca.code_id].try(:hssp2_stratprog_val)
              add_codes_to_row(row, codes, Code.deepest_nesting, :short_display)
              add_codes_to_row(row, codes, Code.deepest_nesting, :official_name)
              row << last_code.try(:short_display)
              row << last_code.try(:official_name)
              row << last_code.try(:type)
              row << last_code.try(:sub_account)
              row << last_code.try(:nha_code)
              row << last_code.try(:nasa_code)
              row << codes_cache[district_coding.code_id].try(:short_display)
              add_codes_to_row(row, cost_category_codes, CostCategory.deepest_nesting, :short_display)

              csv << row
            end
          end
        end
      end
    end

    def build_header
      amount_type = @is_budget ? 'Budget' : 'Spent'

      row = []
      row << "Activity Name"
      row << "Activity Description"
      row << "Q1"
      row << "Q2"
      row << "Q3"
      row << "Q4"
      row << "Districts"
      row << "# of sub-activities"
      row << "# of facilities implementing"
      row << "Sub-implementers"
      row << "Data Source"
      row << "Implementer"
      row << "Institutions Assisted"
      row << "Beneficiaries"
      row << "ID"
      row << "Currency"
      row << "Total #{amount_type}"
      row << "Converted #{amount_type} (USD)"
      row << "National?"
      row << "Possible Duplicate?"
      row << 'Funding Source'
      row << 'Funding Source Type'
      row << "Classified #{amount_type}"
      row << "Classified #{amount_type} Percentage"
      row << "Converted Classified #{amount_type} (USD)"
      row << "HSSPII Strat obj"
      row << "HSSPII Strat prog"
      Code.deepest_nesting.times{ row << "Code" }
      Code.deepest_nesting.times{ row << "Official Code" }
      row << "Lowest level Code"
      row << "Lowest level Official Code"
      row << "Code type"
      row << "Code sub account"
      row << "Code nha code"
      row << "Code nasa code"
      row << "District"
      CostCategory.deepest_nesting.times{ row << "Cost Category" }

      row
    end

    def get_fake_ca
      @fake ||= CodeAssignment.new
    end

    def fake_one_assignment_if_none(amount_total, codings)
      fake_ca = get_fake_ca
      fake_ca.cached_amount = amount_total # update the fake ca with current activity amount

      codings.empty? ? [fake_ca] : codings
    end

    def fake_one_funding_source_if_none(funding_sources)
      if funding_sources.empty?
        if @is_budget
          [FundingFlow.new(:budget => 1)]
        else
          [FundingFlow.new(:spend => 1)]
        end
      else
        funding_sources
      end
    end

    def get_percentage(amount_total, amount)
      amount_total && amount_total > 0 ? amount / amount_total : 0
    end

    def get_institutions_assisted(activity)
      activity.organizations.map{|o| o.name}.join(' | ')
    end

    def get_beneficiaries(activity)
      activity.beneficiaries.map{|o| o.short_display}.join(' | ')
    end

    def get_hc_sub_activity_count(activity)
      @hc_sub_activities.detect{|sa| sa.activity_id == activity.id}.try(:total) || 0
    end
end
