require 'lib/ActAsDataElement'
require 'lib/ReportHelpers'
require 'validators'

class DataResponse < ActiveRecord::Base

  include ActsAsDateChecker
  include ReportHelpers

  # Commentable
  acts_as_commentable

  # Associations

  has_many :activities, :dependent => :destroy
  has_many :sub_activities, :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  @@data_associations = %w[activities funding_flows projects]

  has_many    :users_currently_completing,
              :class_name => "User",
              :foreign_key => :data_response_id_current

  belongs_to  :responding_organization,
              :class_name => "Organization",
              :foreign_key => "organization_id_responder"

  belongs_to  :data_request

  # Validations
  validates_presence_of :data_request_id
  validates_presence_of :organization_id_responder
  validates_presence_of :currency

  validates_date :fiscal_year_start_date, :on => :update
  validates_date :fiscal_year_end_date, :on => :update
  validates_dates_order :fiscal_year_start_date, :fiscal_year_end_date, :message => "Start date must come before End date.", :on => :update

  # Named scopes
  named_scope :available_to, lambda { |current_user|
    if current_user.nil?
      {:conditions => {:id => -1}} #return no records
    elsif current_user.role?(:admin)
      {}
    else
      {:conditions=>{:organization_id_responder => current_user.organization.id}}
    end
  }

  named_scope :unfulfilled, :conditions => ["complete = ?", false]
  named_scope :submitted,   :conditions => ["submitted = ?", true]

  def self.in_progress
    self.find(:all, :include => [:responding_organization, :projects], :conditions => ["submitted = ? or submitted is NULL", false]).select{|dr| dr.projects.size > 0 or dr.activities.size > 0}
  end

  def self.remove_security
    with_exclusive_scope {find(:all)}
  end

  def self.options_hash_for_empty
    h = {}
    h[:joins] = @@data_associations.collect do |assoc|
      "LEFT JOIN #{assoc} ON data_responses.id = #{assoc}.data_response_id"
    end
    h[:conditions] = @@data_associations.collect do |assoc|
      "#{assoc}.data_response_id IS NULL"
    end.join(" AND ")
    h
  end

  #named_scope :empty, options_hash_for_empty
  def self.empty
    drs = self.find(:all, options_hash_for_empty)#, :include => {:responding_organization => :users})
    #GN: commented out optimization, this broke the method, returned too many records
    drs.select do |dr|
      (["Agencies", "Donors", "Donor", "Implementer", "Implementers", "International NGO"]).include?(dr.responding_organization.raw_type)
    end
  end

  def empty?
    activities.empty? && projects.empty? && funding_flows.empty?
  end

  def organization
    responding_organization #for convenience
  end

  # Law of Demeter methods
#  %w[projects activities funding_flows].each do |assoc|
#    %w[spend budget].each do |total_method|
#      method_name = "#{assoc}_total_#{total_method}"
#      def method_name
#        send(assoc).sum {|m| m.send(total_method)}
#      end
#    end
#  end

  def status
    return "Empty / Not Started" if empty?
    return "Submitted" if submitted
    return "In Progress"
  end

  def total_project_budget
    projects.inject(0) {|sum,p| p.budget.nil? ? sum : sum + p.budget}
  end

  def total_project_spend
    projects.inject(0) {|sum,p| p.spend.nil? ? sum : sum + p.spend}
  end

  def total_project_budget_RWF
    projects.inject(0) {|sum,p| p.budget.nil? ? sum : sum + p.budget_RWF}
  end

  def total_project_spend_RWF
    projects.inject(0) {|sum,p| p.spend.nil? ? sum : sum + p.spend_RWF}
  end

  def unclassified_activities_count
    activities.only_simple.unclassified.count
  end

  def total_activity_spend
    total_activity_method("spend")
  end

  def total_activity_budget
    total_activity_method("budget")
  end

  def total_activity_spend_RWF
    total_activity_method("spend_RWF")
  end

  def total_activity_budget_RWF
    total_activity_method("budget_RWF")
  end

  def total_activity_method(method)
    activities.only_simple.inject(0) do |sum, a|
      unless a.nil? or !a.respond_to?(method) or a.send(method).nil?
        sum + a.send(method)
      else
        sum
      end
    end
  end

  def currency
    c = read_attribute(:currency)
    return c unless c.blank?
    Money.default_currency
  end

end



# == Schema Information
#
# Table name: data_responses
#
#  id                                :integer         primary key
#  data_element_id                   :integer
#  data_request_id                   :integer         indexed
#  complete                          :boolean         default(FALSE)
#  created_at                        :timestamp
#  updated_at                        :timestamp
#  organization_id_responder         :integer         indexed
#  currency                          :string(255)
#  fiscal_year_start_date            :date
#  fiscal_year_end_date              :date
#  contact_name                      :string(255)
#  contact_position                  :string(255)
#  contact_phone_number              :string(255)
#  contact_main_office_phone_number  :string(255)
#  contact_office_location           :string(255)
#  submitted                         :boolean
#  submitted_at                      :timestamp
#  projects_count                    :integer         default(0)
#  comments_count                    :integer         default(0)
#  activities_count                  :integer         default(0)
#  sub_activities_count              :integer         default(0)
#  activities_without_projects_count :integer         default(0)
#

