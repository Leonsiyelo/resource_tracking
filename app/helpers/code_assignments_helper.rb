module CodeAssignmentsHelper
  def friendly_name_for_coding_copy(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingSpend'
      'Purposes'
    when 'CodingBudgetDistrict', 'CodingSpendDistrict'
      'Locations'
    when 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization'
      'Inputs'
    when 'ServiceLevelBudget', 'ServiceLevelSpend'
      'Service Levels'
    end
  end

  def spend_or_budget(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization'
      "budget"
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization'
      "expenditure"
    end
  end


  def tab_class(activity, coding_type)
    classes = []
    classes << 'incomplete' unless activity.classified_by_type?(coding_type)
    classes << 'selected' if params[:coding_type] == coding_type
    classes.join(' ')
  end
end
