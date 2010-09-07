class ApplicationController < ActionController::Base
  protect_from_forgery

  def to_jqgrid_json(model)
    fields = params["fields"].split(",")

    find = {}
    find[:select] = params["fields"] + ",id"
    find[:order] = params["sidx"] + " " + params["sord"] unless params["sidx"].empty?
    conditions = filter_bar_conditions(fields,params)
    find[:conditions] = conditions unless conditions.empty?

    result_rows = model.find(:all,find)
    row_count = result_rows.length

    result = {}
    total_pages = (row_count/params["rows"].to_i)+1
    result[:page] = params["page"].to_i
    result[:records] = row_count
    result[:total] = total_pages

    rows = []
    result_rows.each do |row|
      cell_value = []
      fields.each do |field|
        cell_value << row[field]
      end
      rows << {:id => row.id, :cell => cell_value}
    end

    result[:rows] = rows
    return result
  end

  def filter_bar_conditions(fields,params)
    conditions = ""
    fields.each do |field|
      conditions << "#{field} LIKE '#{params[field]}%' AND " unless params[field].nil?
    end
    conditions.chomp("AND ")
  end
end

