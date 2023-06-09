<? extend('master.php') ?>
<? startblock('extra_head') ?>
<script type="text/javascript" language="javascript">
    $(document).ready(function() {
       var order_id = "<?php echo isset($order_id) ? $order_id : ''; ?>";
       $('#order_id').val(order_id);
	   build_grid("orders_grid","",<? echo $grid_fields; ?>,<? echo $grid_buttons; ?>);
	   $('.checkall').click(function () {
		   $('.chkRefNos').prop('checked', $(this).prop('checked')); 
	   });

/*
       build_grid("orders_grid","",<? echo $grid_fields; ?>,<? echo $grid_buttons; ?>);
       $('.checkall').click(function () {
         $('.chkRefNos').prop('checked', $(this).prop('checked'));
       });*/
       var resellerid ="<?php echo isset($reseller_id) ? $reseller_id : ''; ?>";
        $('.reseller_id_search_drp').val(resellerid);
       /* build_grid("orders_grid","",<? echo $grid_fields; ?>,<? echo $grid_buttons; ?>);
        $('.checkall').click(function () {
             $('.chkRefNos').prop('checked', $(this).prop('checked'));
        });
        build_grid("orders_grid","",<? echo $grid_fields; ?>,<? echo $grid_buttons; ?>);
        $('.checkall').click(function () {
            $('.chkRefNos').prop('checked', $(this).prop('checked')); 
        });*/
        $("#order_search_btn").click(function(){ 
            post_request_for_search("orders_grid","","orders_list_search");
        });        
        $("#id_reset").click(function(){
            clear_search_request("orders_grid","");
        });
        var from_date = date + " 00:00:00";
        var to_date = date + " 23:59:59";

        $("#billing_date_from_date").datetimepicker({
	    value:from_date,
            uiLibrary: 'bootstrap4',
            iconsLibrary: 'fontawesome',
            modal:true,
            format: 'yyyy-mm-dd HH:MM:ss',
            footer:true
         });
         $("#billing_date_to_date").datetimepicker({
	     value:to_date,
            uiLibrary: 'bootstrap4',
            iconsLibrary: 'fontawesome',
            modal:true,
            format: 'yyyy-mm-dd HH:MM:ss',
            footer:true
         });  
         $(".reseller_id_search_drp").change(function(){
            
                if(this.value!=""){
                    $.ajax({
                        type:'POST',
                        url: "<?= base_url()?>/invoices/reseller_customerlist/",
                        data:"reseller_id="+this.value, 
                        success: function(response) {
                             $("#accountid_search_drp").html(response);
                             $("#accountid_search_drp").prepend("<option value='' selected='selected'><?php echo gettext('--Select--'); ?></option>");
                             $('.accountid_search_drp').selectpicker('refresh');
                        }
                    });
                }else{
                        $("#accountid_search_drp").html("<option value='' selected='selected'><?php echo gettext('--Select--'); ?></option>");
                        $('.accountid_search_drp').selectpicker('refresh');
                    }   
        });
        $(".reseller_id_search_drp").change(); 
    });
</script>
<? endblock() ?>

<? startblock('page-title') ?>
<?= $page_title ?>
<? endblock() ?>

<? startblock('content') ?>

<section class="slice color-three">
	<div class="w-section inverse p-0">
		<div class="col-12">
			<div class="portlet-content mb-4" id="search_bar"
				style="display: none">
                        <?php echo $form_search; ?>
                </div>
		</div>
	</div>
</section>

<section class="slice color-three pb-4">
	<div class="w-section inverse p-0">
		<div class="card col-md-12 pb-4">
			<table id="orders_grid" align="left" style="display: none;"></table>

		</div>
	</div>
</section>
<? endblock() ?>	
<? end_extend() ?>  
