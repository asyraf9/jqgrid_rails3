class ApplicationController < ActionController::Base
  protect_from_forgery

  #res needs to be a Relations object, which is returned by all the new ActiveRecord query methods.
  #for now, find does not return a Relations object, so use order("id ASC") instead of find(:all) or Model.all
  #temporary fix until rails 3.2 I think
  def to_jqgrid_json(res)
    fields = params[:fields].gsub(/[\[\] ]/,"").split(",")

    #setup model query conditions and run paginate find
    find = {}
    filter_conditions = filter_bar_conditions(fields,params)
    search_conditions = adv_search_conditions(params[:filters])
    find[:select] = params[:fields].gsub(/[\[\] ]/,"") + ",id"
    find[:order] = params[:sidx] + " " + params[:sord] unless params[:sidx].empty?
    find[:conditions] = ""
    find[:conditions] << filter_conditions unless filter_conditions.empty?
    find[:conditions] << "AND " + search_conditions unless search_conditions.empty?
    find[:page] = params[:page]
    find[:per_page] = params[:rows]
    result_array = res.select(find[:select]).where(find[:conditions])
    result_rows = result_array.paginate(:page => find[:page], :per_page => find[:per_page], :order => find[:order])

    #prepare initial jqGrid JSON params
    result = {}
    result[:page] = params[:page].to_i
    result[:records] = result_rows.total_entries
    result[:total] = result_rows.total_pages
    #prepare jqGrid JSON data rows
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

  #this method prepares the search conditions specified in filterToolbar
  def filter_bar_conditions(fields,params)
    conditions = ""
    fields.each do |field|
      conditions << "#{field} LIKE '#{params[field]}%' AND " unless params[field].nil?
    end
    conditions.chomp("AND ")
  end

  #this method prepares the search conditions specified in Advanced search
  def adv_search_conditions(filters)
    conditions = ""
    unless filters.nil? || filters.empty?
      filters_data = ActiveSupport::JSON.decode(filters)
	    groupOp = filters_data["groupOp"]
	    filters_data["rules"].each do |search_row|
        data = "#{search_row["data"]}"
	      operator = case search_row["op"]
          when "eq" then " = "
          when "ne" then " <> "
          when "lt" then " < "
          when "le" then " <= "
          when "gt" then " > "
          when "ge" then " >= "
        end
        conditions << "#{search_row["field"]}#{operator}#{data} AND "
      end
    end
    conditions.chomp("AND ")
  end

#	if( $fld=='id' || $fld =='invdate' || $fld=='name' || $fld=='amount' || $fld=='tax' || $fld=='total' || $fld=='note' ) {
#		$fldata = Strip($_REQUEST['searchString']);
#		$foper = Strip($_REQUEST['searchOper']);
#		// costruct where
#		$wh .= " AND ".$fld;
#		switch ($foper) {
#			case "bw":
#				$fldata .= "%";
#				$wh .= " LIKE '".$fldata."'";
#				break;
#			case "eq":
#				if(is_numeric($fldata)) {
#					$wh .= " = ".$fldata;
#				} else {
#					$wh .= " = '".$fldata."'";
#				}
#				break;
#			case "ne":
#				if(is_numeric($fldata)) {
#					$wh .= " <> ".$fldata;
#				} else {
#					$wh .= " <> '".$fldata."'";
#				}
#				break;
#			case "lt":
#				if(is_numeric($fldata)) {
#					$wh .= " < ".$fldata;
#				} else {
#					$wh .= " < '".$fldata."'";
#				}
#				break;
#			case "le":
#				if(is_numeric($fldata)) {
#					$wh .= " <= ".$fldata;
#				} else {
#					$wh .= " <= '".$fldata."'";
#				}
#				break;
#			case "gt":
#				if(is_numeric($fldata)) {
#					$wh .= " > ".$fldata;
#				} else {
#					$wh .= " > '".$fldata."'";
#				}
#				break;
#			case "ge":
#				if(is_numeric($fldata)) {
#					$wh .= " >= ".$fldata;
#				} else {
#					$wh .= " >= '".$fldata."'";
#				}
#				break;
#			case "ew":
#				$wh .= " LIKE '%".$fldata."'";
#				break;
#			case "ew":
#				$wh .= " LIKE '%".$fldata."%'";
#				break;
#			default :
#				$wh = "";
#		}
#	}
#}
#  end
end

