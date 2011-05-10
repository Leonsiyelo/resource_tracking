require 'fastercsv'

class Reports::MapFacilitiesByPartner
  include Reports::Helpers

  def initialize(type)
    @is_budget = is_budget?(type)

    #organizations   = [Organization.find_by_name("Muhima HD District Hospital | Nyarugenge"), Organization.find_by_name("CHK/CHUK National Hospital | Nyarugenge")] # FOR DEBUG
    @organizations   = Organization.all(:conditions => ["fosaid is not null"])
    prepare_districts_hash
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @organizations.each{|organization| build_row(csv, organization)}
    end
  end

  private

    def prepare_districts_hash
      @districts_hash = {}
      @organizations.each do|organization|
        @districts_hash[organization] = {}
        @districts_hash[organization][:total] = 0
        @districts_hash[organization][:partners] = {} # partner => amount
        dr = organization.data_responses.last

        # if have my own DR, pull lots of info from there
        # otherwise get who gives me money by activities
        if dr && !dr.empty?
          puts dr.id
          in_flows = organization.in_flows.find(:all,
                                  :conditions => ["data_response_id = ?", dr.id],
                                  :include => :project)
          in_flows.each do |flow|
            set_amounts(organization, flow.from, in_flow_amount(flow))
          end
        else
          activities = organization.provider_for.canonical
          #preload_district_associations(activities, @is_budget) # eager-load
          activities.each do |activity|
            set_amounts(organization, activity.organization, activity_amount(activity))
          end
        end
      end
    end

    def set_amounts(organization, partner, amount)
      @districts_hash[organization][:total] += amount

      if @districts_hash[organization][:partners][partner]
        @districts_hash[organization][:partners][partner] += amount
      else
        @districts_hash[organization][:partners][partner] = amount unless amount == 0
      end
    end

    def build_header
      row = []

      row << "FOSAID"
      row << "District"
      row << "Facility Name"
      row << "Facility Type"
      row << "Latitude"
      row << "Longitude"
      row << "Catchment Population"
      row << "Total #{@is_budget ? 'Budget' : 'Spent'}"
      row << "Total #{@is_budget ? 'Budget' : 'Spent'} Per Capita"
      row << "1st Development Partner by Amount"
      row << "Amount"
      row << "All DP's"
      max_partners_length.times do |i|
        row << "#{i+2} DP by Amount"
        row << "#{i+2} Amount"
      end

      row
    end

    def build_row(csv, organization)
      row = []

      row << organization.fosaid
      row << organization.locations.last.to_s
      row << organization.to_s.upcase
      row << organization.facility_type
      row << organization.latitude
      row << organization.longitude
      row << organization.catchment_population
      tot = @districts_hash[organization].delete(:total)
      row <<  tot #remove key
      if organization.catchment_population && organization.catchment_population > 0
        row << tot / organization.catchment_population
      else
        row << ""
      end

      add_partners(row, organization)

      csv <<  row
    end

    # TODO: refactor - duplicate method
    def add_partners(row, organization)
      partners = @districts_hash[organization][:partners]

      if partners.present?
        sorted_partners = sort_partners(partners)
        top_partner     = sorted_partners.first

        row << top_partner[0].to_s
        row << n2c(top_partner[1])
        row << full_partners_list(sorted_partners)

        sorted_partners.shift # dont show top_partner again
        sorted_partners.each do |partner|
          row << partner[0].to_s
          row << n2c(partner[1])
        end
      end
    end

    def activity_amount(activity)
      amount = (@is_budget ? activity.budget_in_usd : activity.spend_in_usd) || 0
      amount * Money.default_bank.get_rate(activity.currency, :USD)
    end

    def in_flow_amount(funding_flow)
      amount = (@is_budget ? funding_flow.budget : funding_flow.spend) || 0
      amount * Money.default_bank.get_rate(funding_flow.currency, :USD)
    end

    def max_partners_length
      partner_sizes = @districts_hash.map{|k,v| v[:partners]}.map{|partner| partner.size}
      partner_sizes.present? ? partner_sizes.max - 1 : 0
    end

    def sort_partners(partners)
      partners.sort{|a,b| b[1] <=> a[1]} #sort by value, desc
    end

    def full_partners_list(sorted_partners)
      sorted_partners.map{|partner| "#{partner[0].to_s}(#{n2c(partner[1])})"}.join(",")
    end
end
