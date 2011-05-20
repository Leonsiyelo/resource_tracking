class OrganizationsController < ApplicationController
  
  def index
    @organizations = Organization.find(:all, :conditions => ["name like ?", '%' + params[:q] + '%'], :limit => 10)
   
    @json = []
    @organizations.each {|org| @json << {:id => org.id, :value => org.name}}

    respond_to do |format|
      format.html
      format.js {render :json => @json.to_json}
    end
  end
  def create
    organization = Organization.new
    organization.name = params[:name]
    organization.save
    respond_to do |format|
      format.js {render :json => organization.to_json}
    end
  end
end

