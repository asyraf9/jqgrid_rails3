module ApplicationHelper
  def jqgrid2(model, opt={})
      #In the case of nested routes, set the path option below to your nested path
      opt[:path] ||= model.to_s.tableize

      #Random HTML id - don't need to do anything for this'
      opt[:id] ||= model.to_s.pluralize + '_' + rand(36**4).to_s(36)
      opt[:pager] ||= "##{opt[:id]}_pager" #The '#' at the start marks the string as a function, else it will be a string in json
      opt[:toppager] ||= true

      #Default Grid options Begin
      opt[:fields] ||= model.column_names.to_s
      opt[:caption] ||= model.to_s.titleize.pluralize
      id = opt[:caption].parameterize
      opt[:url] ||=  %Q(/grid_data/#{model.to_s.tableize}/index?fields=#{opt[:fields]})     #%Q(#{url_for opt[:path]}?fields=#{opt[:fields]})
      opt[:editurl] ||= %Q(/grid_data/#{model.to_s.tableize}/edit)
      opt[:colNames] ||= opt[:fields].gsub(/[\[\]]/,"").split(",").collect {|col| col.titleize}
      opt[:colModel] ||= fields_to_colmodel(opt[:fields])
      opt =
        {
          :datatype            => 'json',
          :rowNum              => 10,
          :rowList             => [10,25,50,100],
          :sortname            => '',
          :sortorder           => '',
          :height              => 150,
          :autowidth           => true,
          :viewrecords         => true,
          :rownumbers          => false,
          :scrollrows          => true,
          :gridview            => false,
          :inline_edit         => false,
          :multiselect         => true,
          :multiboxonly        => true,
        }.merge(opt)
      #Default Grid opt End

      opt[:pager_opt]||={}
      #Default Pager options Begin
      opt[:pager_opt] =
        {
          :edit                  => false,
          :add                   => false,
          :del                   => false,
          :refresh               => true,
          :search                => false,
          :view                  => false,
          :cloneToTop            => true,
        }.merge(opt[:pager_opt])
      opt[:pager_opt][:editoptions] ||= ""
      opt[:pager_opt][:addoptions] ||= ""
      opt[:pager_opt][:deleteoptions] ||= ""
      opt[:pager_opt][:searchoptions] ||= ""
      #Default Pager options End

      #Default Interaction options Begin
      #TODO: Insert all the other Interaction methods in here
#      opt[:ondblClickRow] ||= %Q(#
#            function(rowId, iRow, iCol, e)
#            {
#              if(rowId)
#              {
#                window.location = '#{url_for(:controller => model.name.pluralize,:action => 'show')}' + '/' + rowId;
#              }
#            })


      #Default Interaction options End

      #Grid Javascript Begin
      #TODO: refactor this to remove all the crappy coding for differentiating js method and json hashes
      #TODO: edit CSS for the buttons - font size and box margin and align right
      result = %Q(
        <script type="text/javascript">

          jQuery(document).ready(function(){
            jQuery('##{opt[:id]}').jqGrid(
              #{opt.to_json(:except => [:pager_opt,:fields,:id, :path])}
            ).jqGrid('navGrid','##{opt[:id]}_pager',
            #{opt[:pager_opt].to_json(:except =>[:editoptions,:addoptions,:deleteoptions,:searchoptions])},
            {#{opt[:pager_opt][:editoptions]}},
            {#{opt[:pager_opt][:addoptions]}},
            {#{opt[:pager_opt][:deleteoptions]}},
            {#{opt[:pager_opt][:searchoptions]}}
            ).jqGrid('filterToolbar'
            ).jqGrid('navButtonAdd', "##{opt[:id]}_toppager", {title:"Advanced Search", caption:"", buttonicon:"ui-icon-search", onClickButton:search_grid}
            ).jqGrid('navButtonAdd', "##{opt[:id]}_toppager", {title:"Filter Results", caption:"", buttonicon:"ui-icon-wrench", onClickButton:filter_toggle}
            ).jqGrid('navSeparatorAdd', "##{opt[:id]}_toppager"
            ).jqGrid('navButtonAdd', "##{opt[:id]}_toppager", {title:"New Record", caption:"", buttonicon:"ui-icon-plus", onClickButton:link_to_new}
            ).jqGrid('navButtonAdd', "##{opt[:id]}_toppager", {title:"Edit Row", caption:"", buttonicon:"ui-icon-pencil", onClickButton:link_to_edit}
            ).jqGrid('navButtonAdd', "##{opt[:id]}_toppager", {title:"Delete Row(s)", caption:"", buttonicon:"ui-icon-trash", onClickButton:delete_rows});

            jQuery('.ui-search-toolbar').css("display","none");
          });

          function delete_rows(){
            var gr = jQuery("##{opt[:id]}").jqGrid('getGridParam','selarrrow');
            if( gr.length > 0 ) jQuery("##{opt[:id]}").jqGrid('delGridRow',gr,{url:"/grid_data/#{model.to_s.tableize}/destroy"});
            else alert("Please Select Row(s)!");
          }

          function link_to_new(){
            window.location = '#{url_for(:controller => model.to_s.downcase.pluralize,:action => 'new')}';
          }

          function link_to_edit(){
            var rowID = jQuery("##{opt[:id]}").jqGrid('getGridParam', 'selrow');
            if( rowID != null ) {
              window.location = '/#{model.to_s.downcase.pluralize}/' + rowID + '/edit';
            } else alert("Please Select A Row to Edit!")
          }

          function search_grid(){
            jQuery("##{opt[:id]}").jqGrid('searchGrid', {multipleSearch:true,sopt:['eq','ne','lt','le','gt','ge']});
          }

          function filter_toggle(){
            if(jQuery(".ui-search-toolbar").css("display")=="none") {
              jQuery(".ui-search-toolbar").css("display","");
            } else {
              jQuery(".ui-search-toolbar").css("display","none");
            }
          }


        </script>

        <table id="#{opt[:id]}" class="scroll ui-state-default" cellpadding="" cellspacing="0"></table>
        <div id="#{opt[:id]}_toppager" class="scroll" style="text-align:center;"></div>
        <div id="#{opt[:id]}_pager" class="scroll" style="text-align:center;"></div>

        )

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
end

