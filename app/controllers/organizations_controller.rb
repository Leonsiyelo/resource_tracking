class OrganizationsController < ApplicationController
  
  def index
    @organizations = Organization.find(:all, 
                                       :conditions => ["name like ?", "%#{params[:term]}%"], 
                                       :limit => 10)
   
    @json = @organizations.map{|org| {:id => org.id, :value => org.name, :label => org.name}}

    respond_to do |format|
      format.html
      format.json { render :json => @json }
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

