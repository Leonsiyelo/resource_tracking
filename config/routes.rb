ActionController::Routing::Routes.draw do |map|

  #map.other_cost_coding "other_costs/code", :controller => 'other_costs', :action =>
  map.data_requests 'data_requests', :controller => 'data_requests', :action => :index #until we flesh out this model

  map.funding_sources_data_entry "funding_sources", :controller => 'funding_sources', :action => 'index'
  map.providers_data_entry "providers", :controller => 'providers', :action => 'index'

  map.resources :projects,
    :collection => {:browse => :get},
    :member => {:select => :post}, :active_scaffold => true

  map.resources :organizations,
    :collection => {:browse => :get},
    :member => {:select => :post}, :active_scaffold => true

  map.resources :activities, :active_scaffold => true do |activity|

    activity.resource  :budget, :path_prefix => '/activities/:activity_id/classification',
                                :controller => :budget_classification,
                                :only => [ :show, :update ]
    activity.resource  :expenditure,  :path_prefix => '/activities/:activity_id/classification',
                                      :controller => :expenditure_classification,
                                      :only => [ :show, :update ]
  end

  # AS redirect helpers
  map.popup_coding 'popup_coding', :controller => :activities, :action => :popup_coding
  map.popup_other_cost_coding "popup_other_cost_coding", :controller => 'other_costs', :action => 'popup_coding'

  map.resources :indicators, :active_scaffold => true
  map.resources :line_items, :active_scaffold => true
  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :funding_flows, :active_scaffold => true
  map.resources :codes, :active_scaffold => true
  map.resources :activity_cost_categories, :active_scaffold => true
  map.resources :other_costs, :active_scaffold => true
  map.resources :other_cost_types, :active_scaffold => true

  map.resources :users, :active_scaffold => true

  map.resource :user_session
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  %w[activities funding_flows projects providers funding_sources model_helps comments other_costs].each do |model|
    map.create_from_file model+"/create_from_file", :controller => model, :action => "create_from_file"
  end

  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact ngo_dashboard govt_dashboard admin_dashboard].join('|'))

  map.root :controller => 'static_page', :action => 'index' # a replacement for public/index.html


end

