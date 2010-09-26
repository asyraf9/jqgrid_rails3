class GridDataController < ApplicationController
  protect_from_forgery
  respond_to :json

  def index
    model = params["model"].classify.constantize
    fields = params[:fields].gsub(/[\[\] ]/,"")
    fields_array = fields.split(",")

    #setup model query conditions and run paginate find
    find = {}
    conditions = search_conditions(fields_array,params,params[:filters],params[:conditions])
    find[:select] = fields + ",id"
    find[:order] = params[:sidx] + " " + params[:sord] unless params[:sidx].empty?
    find[:conditions] = ""
    find[:conditions] << conditions unless conditions.empty?
    find[:page] = params[:page]
    find[:per_page] = params[:rows]
    result_array = model.select(find[:select]).where(find[:conditions])
    result_rows = result_array.paginate(:page => find[:page], :per_page => find[:per_page], :order => find[:order])
    #TODO: figure out why you need to do a to_json with respond_with
    @result = setup_jqgrid_response(result_rows,params[:page],fields_array).to_json

    respond_with @result
  end

  def destroy
    model = params["model"].classify.constantize
    ids = params[:id].split(",")
    res = model.find(ids)
    if res.is_a?(Array)
      res.each{|m| m.destroy}
    else
      res.destroy
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
      format.json { head:ok }
    end
  end

  def search_conditions(fields,params,filters,user_specific_conditions)
    conditions = ""
    #this method prepares the search conditions manually specified by the user
    #TODO: need to better dish this out - this currently requires sql statements, but we should be passing hashes.
    conditions << user_specific_conditions + "AND " unless user_specific_conditions.nil?
    #this method prepares the search conditions specified in filterToolbar
    fields.each do |field|
      conditions << "#{field} LIKE '#{params[field]}%' AND " unless params[field].nil?
    end
    #this method prepares the search conditions specified in Advanced search
    unless filters.nil? || filters.empty?
      filters_data = ActiveSupport::JSON.decode(filters)
	    groupOp = filters_data["groupOp"]
	    filters_data["rules"].each do |search_row|
	     #TODO: finish all the other 'op's defined in jqgrid search
        operator = case search_row["op"]
          when "eq" then " = "
          when "ne" then " <> "
          when "lt" then " < "
          when "le" then " <= "
          when "gt" then " > "
          when "ge" then " >= "
        end
        data = case search_row["op"]
          when "eq","ne","lt","le","gt","ge" then to_sql_params(search_row["data"])
          else search_row["data"]
        end
        conditions << "#{search_row["field"]}#{operator}#{data} AND "
      end
    end
    conditions.chomp("AND ")
  end

  def to_sql_params(data)
    if data.is_a? Numeric
      return data
    else
      return "'" + data.to_s + "'"
    end
  end

  #res needs to be a Relations object, which is returned by all the new ActiveRecord query methods.
  #for now, find does not return a Relations object, so use order("id ASC") instead of find(:all) or Model.all
  #temporary fix until rails 3.2 I think
  def setup_jqgrid_response(res, page, fields)
    #prepare initial jqGrid JSON params
    result = {}
    result[:page] = page.to_i
    result[:records] = res.total_entries
    result[:total] = res.total_pages
    #prepare jqGrid JSON data rows
    rows = []
    res.each do |row|
      cell_value = []
      fields.each do |field|
        cell_value << row[field]
      end
      rows << {:id => row.id, :cell => cell_value}
    end
    result[:rows] = rows
    return result
  end


end

