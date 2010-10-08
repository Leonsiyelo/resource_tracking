# == Schema Information
#
# Table name: code_assignments
#
#  id            :integer         primary key
#  activity_id   :integer
#  code_id       :integer
#  code_type     :string(255)
#  amount        :decimal(, )
#  type          :string(255)
#  percentage    :decimal(, )
#  cached_amount :decimal(, )
#

class CodingBudgetCostCategorization < BudgetCodeAssignment

  def self.available_codes(activity = nil)
    CostCategory.roots
  end
end
