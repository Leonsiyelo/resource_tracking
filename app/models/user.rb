class User < ActiveRecord::Base
  acts_as_authentic

  attr_accessible :full_name, :email, :username,
                  :password, :password_confirmation,
                  :organization_id, :organization, :roles

  # Associations
  has_many  :comments
  belongs_to :organization, :counter_cache => true
  has_many :data_responses, :through => :organization
  belongs_to :current_data_response, :class_name => "DataResponse",
              :foreign_key => :data_response_id_current

  # Validations
  validates_presence_of  :username, :email, :organization_id
  validates_uniqueness_of :email, :username, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :within => 8..64, :on => :create

  # Named scopes
  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }

  def self.remove_security
    with_exclusive_scope {find(:all)}
  end

  # Authlogic
  def self.find_by_username_or_email(login)
    self.find(:first, :conditions => ["username = :login OR email = :login", {:login => login}])
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end



  ROLES = %w[admin reporter activity_manager]

  def roles=(roles)
    roles = roles.collect {|r| r.to_s} # allows symbols to be passed in
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    roles.include? role.to_s
  end

  def admin?
    role?('admin')
  end

  def to_s
    username
  end

  # Law of Demeter methods
  def organization_status
    return "No Organization" if organization.nil?
    current_dr = current_data_response
    current_dr ||= organization.data_responses.first
    return "No Data Response" if current_dr.nil?
    current_dr.status
  end

end





# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  username                 :string(255)
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null
#

