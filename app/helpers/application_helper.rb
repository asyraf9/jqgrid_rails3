module ApplicationHelper
  def jqgrid2(model, opt={})
      #In the case of nested routes, set the path option below to your nested path
      opt[:path] ||= model.to_s.tableize

      #Random HTML id
      opt[:id] ||= model.to_s.pluralize + '_' + rand(36**4).to_s(36)
      opt[:pager] ||= "##{opt[:id]}_pager" #The '#' at the start marks the string as a function, else it will be a string in json

      #Default Grid options Begin
      opt[:fields] ||= model.column_names.to_s
      opt[:caption] ||= model.to_s.titleize.pluralize
      id = opt[:caption].parameterize
      opt[:url] ||=  %Q(#{url_for opt[:path]}?fields=#{opt[:fields]})
      opt[:colNames] ||= opt[:fields].split(",").collect {|col| col.titleize}
      opt[:colModel] ||= fields_to_colmodel(opt[:fields])
      opt =
        {
          :datatype            => 'json',
          :jsonReader          => {:repeatItems => false},
          :rowNum              => 10,
          :rowList             => [10,25,50,100],
          :sort_name           => '',
          :sort_order          => '',
          :height              => 150,
          :autowidth           => false,
          :viewrecords         => true,
          :rownumbers          => false,
          :scrollrows          => true,
          :gridview            => false,
          :search              => true,
          :add                 => false,
          :edit                => false,
          :delete              => false,
          :inline_edit         => false,
          :inline_edit_handler => '',
          :error_handler       => '',
        }.merge(opt)
      opt[:ondblClickRow] ||= %Q(#
      function(rowId, iRow, iCol, e)
      {
        if(rowId)
        {
          window.location = '#{url_for(:controller => model.name.pluralize,:action => 'show')}' + '/' + rowId;
        }
      }
      )
      #Default Grid opt End

      opt[:pager_opt] = {}
      #Default Pager options Begin
      opt[:pager_opt][:edit] ||= false
      opt[:pager_opt][:add] ||= false
      opt[:pager_opt][:del] ||= false
      opt[:pager_opt][:search] ||= false
      opt[:pager_opt][:refresh] ||= false
      opt[:pager_opt][:view] ||= false
      opt[:pager_opt][:editoptions] ||= ""
      opt[:pager_opt][:addoptions] ||= ""
      opt[:pager_opt][:deleteoptions] ||= ""
      opt[:pager_opt][:searchoptions] ||= ""
      #Default Pager options End

      #Grid Javascript Begin
      result = %Q(
        <script type="text/javascript">

          jQuery(document).ready(function(){
          jQuery('##{opt[:id]}').jqGrid(
            #{opt.to_json(:except => [:pager_opt,:fields,:id])}
          ).navGrid('##{opt[:id]}_pager',
          #{opt[:pager_opt].to_json(:except =>[:editoptions,:addoptions,:deleteoptions,:searchoptions])},
          {#{opt[:pager_opt][:editoptions]}},
          {#{opt[:pager_opt][:addoptions]}},
          {#{opt[:pager_opt][:deleteoptions]}},
          {#{opt[:pager_opt][:searchoptions]}}
          ).filterToolbar();
          });
        </script>
        <table id="#{opt[:id]}" class="scroll ui-state-default" cellpadding="" cellspacing="0"></table>
        <div id="#{opt[:id]}_pager" class="scroll" style="text-align:center;"></div>)

        return result.html_safe
      #Grid Javascript End
    end

    def fields_to_colmodel(fields)
      fields_a = fields.split(",")
      colmodel = []
      fields_a.each do |field|
        colmodel << {:name => field,:index =>field}
      end
      colmodel
    end

    def jqgrid_theme(theme)
      includes = capture { stylesheet_link_tag "jqgrid/#{theme}/jquery-ui-1.7.2.custom" }
      includes << capture { stylesheet_link_tag "jqgrid/ui.jqgrid" }
      includes << capture { javascript_include_tag "jqgrid/jquery-1.3.2.min" }
      includes << capture { javascript_include_tag "jqgrid/jquery.jqGrid.min" }
      includes << capture { javascript_include_tag "jqgrid/i18n/grid.locale-en" }
      includes
    end

end

