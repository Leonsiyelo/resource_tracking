class Reports::Countries::ActivitiesController < Reports::BaseController

  def index
    @activities        = Activity.top_by_spent_and_budget({
                         :per_page => 25, :page => params[:page], :sort => params[:sort],
                         :code_ids => Mtef.roots.map(&:id), :type => 'country'})
    @spent_pie_values  = CountryPies::activities_pie("CodingSpend")
    @budget_pie_values = CountryPies::activities_pie("CodingBudget")
  end

  def show
    @activity     = Activity.find(params[:id])
    @treemap      = params[:chart_type] == "treemap" || params[:chart_type].blank?
    code_type     = get_code_type_and_initialize(params[:code_type])

    if @treemap
      @code_spent_values   = CountryTreemaps::treemap(code_type, [@activity], true)
      @code_budget_values  = CountryTreemaps::treemap(code_type, [@activity], false)
    else
      @code_spent_values  = CountryPies::codes_for_activities_pie(code_type, [@activity], true)
      @code_budget_values = CountryPies::codes_for_activities_pie(code_type, [@activity], false)
    end

    @charts_loaded  = @code_spent_values && @code_budget_values

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so some of the charts may be missing!"
    end
  end
end