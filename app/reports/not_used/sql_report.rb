require 'fastercsv'

class Reports::SqlReport
  attr_accessor :select_list, :method_names, :where_body, :code_select_array
  def initialize select_list, method_names, where_body, code_select_array
    @select_list = select_list
    @method_names = method_names
    @where_body = where_body
    @code_select_array = code_select_array
  end

  def csv
    unless @csv_string
      executed_query_results = Organization.find_by_sql query
      @csv_string = FasterCSV.generate do |csv|
        csv << build_header
        executed_query_results.each {|r| csv << build_row(r)}
      end
    else
      @csv_string
    end
  end

  def query_results
    executed_query_results = Organization.find_by_sql query
  end

  protected

  def query
    list = @select_list + code_select_array.collect do |a|
      code_total_for a[0], a[1], a[2], a[3]
    end

    list = list.join ","

    @query = " SELECT
    #{list}
    #{@where_body} "

  end

  def build_header
    (select_list + code_select_array.collect{|c| c[3]}).flatten
  end

  def build_row row
    output_row = []
    method_names.each do |method|
      output_row << row.send(method)
    end
    code_select_array.each do |method|
      output_row << row.send(method[2])
    end
    output_row.flatten
  end

  def code_total_for type, code_id, result_name, header_name
    #TODO add a flag to activities to exclude them if they
    # are parent activities
    "( select sum(code_assignments.cached_amount*currencies.toRWF)
       FROM code_assignments
       INNER JOIN activities on activities.id = code_assignments.activity_id
       INNER JOIN data_responses on data_responses.id = activities.data_response_id
       INNER JOIN currencies on currencies.symbol = data_responses.currency
       LEFT JOIN activities a2 on activities.id=a2.activity_id
       WHERE activities.provider_id = organizations.id
       AND code_assignments.type = '#{type}'
       AND code_assignments.code_id = #{code_id} ) as #{result_name}
       AND a2.activity_id is null" #left join attempts the todo slowly
  end

  def code_total_for_district type, code_id, result_name, header_name
    "( select sum(code_assignments.cached_amount*currencies.toRWF*ca.cached_amount/
   (CASE when ca.type = 'CodingBudgetDistrict'
   THEN activities.budget ELSE activities.spend END))
       FROM code_assignments
       INNER JOIN activities on activities.id = code_assignments.activity_id
       INNER JOIN data_responses on data_responses.id = activities.data_response_id
       INNER JOIN currencies on currencies.symbol = data_responses.currency
       WHERE activities.id = ca.activity_id
       AND code_assignments.type = '#{type}'
       AND 
         CASE WHEN ((ca.type = 'CodingBudgetDistrict' AND code_assignments.type LIKE '%Budget%') OR (ca.type = 'CodingSpendDistrict' AND code_assignments.type LIKE '%Spend%'))
          THEN 1=1
          ELSE 1=0 END  
       AND code_assignments.code_id = #{code_id} ) as #{result_name}"
  end
#
# select f.name, t.name, t.fosaid,  sum(child.budget*currencies.toRWF), sum(child.spend*currencies.toRWF)
#from organizations f
#inner join activities parent on parent.provider_id = f.id
#inner join activities child on child.activity_id = parent.id
#inner join organizations t on t.id = child.provider_id
#inner join data_responses d on d.id = parent.data_response_id
#inner join currencies on currencies.symbol = d.currency
#group by f.name, t.name
#order by t.fosaid 
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
end
