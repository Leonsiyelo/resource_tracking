# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include NumberHelper # gives n2c method available
  include CurrencyHelper

  # include these again so that each module using this module doesnt need to
  include ERB::Util
  include ActionView::Helpers::TextHelper

  # Adds title on page
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Adds javascripts to head
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  # Adds stylesheets to head
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  # Adds keywords to page
  def keywords(page_keywords)
    content_for(:keywords) { page_keywords }
  end

  # Adds description to page
  def description(page_description)
    content_for(:description) { page_description }
  end

  # Creates unique id for HTML document body used for unobtrusive javascript selectors
  def get_controller_id(controller)
    parts = controller.controller_path.split('/')
    parts << controller.action_name
    parts.join('_')
  end

  # Generates proper dashboard url link depending on the type of user
  def user_dashboard_path current_user
    if current_user
      if current_user.role? :admin
        admin_dashboard_path
      elsif current_user.role? :reporter
        reporter_dashboard_path
      elsif current_user.role? :activity_manager
        reporter_dashboard_path
      else
        raise 'user role not found'
      end
    end
  end

  # Generates proper dashboard url link depending on the type of user
  def user_report_dashboard_path current_user
    if current_user
      if current_user.role? :admin
        admin_reports_path
      elsif current_user.role? :reporter
        reporter_reports_path
      else
        raise 'user role not found'
      end
    end
  end

  # need to ensure we dont activate a different 'root' tab when we are on a
  # nested controller of the same name
  # Eg. Dashboard | Activities | Districts
  # where Districts has a nested-controller also called 'Activities'
  def build_admin_nav_tab(tab)
    parent = 'admin'
    active =  current_controller_with_nesting?(parent, tab)
    unless active
      if tab == 'reports'
        active = current_controller_with_nesting?('reports', 'districts') ||
                 current_controller_with_nesting?('districts', 'activities') ||
                 current_controller_with_nesting?('districts', 'organizations') ||
                 current_controller_with_nesting?('admin', 'responses')
      end
    end
    return link_to tab.humanize, { :controller => "/#{parent}/#{tab}" }, :class => ('active' if active)
  end

  # alternative to rails' current_page?() method
  # which doesnt allow you to have extra params in the URI after the
  # controller name.
  def current_controller?(controller_name)
    current = request.path_parameters[:controller].split('/').last
    controller_name == current
  end

  # check the request matches the form 'parent/controller'
  def current_controller_with_nesting?(parent_name, controller_name)
    path    = request.path_parameters[:controller].split('/')
    current = path.pop
    parent  = path.pop
    controller_name == current && parent_name == parent
  end

  def friendly_name(object, truncate_length = 45)
    return "n/a" unless object
    name = object.name.blank? ? object.description : object.name
    return "n/a" if name.blank?
    return truncate(name.titleize, :length => truncate_length)
  end

  # appends a .active class
  def active_if(action_name)
    active = false
    current = controller.action_name.to_sym
    if action_name.is_a?(Array)
      active = true if action_name.include?(current)
    elsif (action_name.class == TrueClass || action_name.class == FalseClass)
      active = action_name
    else
      active = true if action_name == current
    end
    { :class => ('active' if active) }
  end

  # Gifted from will_paginate
  def short_page_entries_info(collection, options = {})
    entry_name = options[:entry_name] ||
      (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

    if collection.total_pages < 2
      case collection.size
      when 0; "0"
      when 1; "<b>1</b> #{entry_name}"
      else;   "<b>all #{collection.size}</b> #{entry_name.pluralize}"
      end
    else
      %{<b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b>} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end

  # returns a javascript friendly definition of a ruby variable, even if the var is nil
  def js_safe(var)
    var.nil? ? "undefined" : var
  end

end
