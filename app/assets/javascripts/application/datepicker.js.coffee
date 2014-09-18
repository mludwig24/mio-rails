check_daterange = (obj) ->
	$obj = jQuery(obj)
	$container = $obj.closest('[data-behaviour="date-range"]')
	$inputs = jQuery('input[data-behaviour="date-picker"]', $container)
	return if isNaN($obj.datepicker('getDate'))
	$lower_part = jQuery($inputs[0])
	$upper_part = jQuery($inputs[1])
	$lower_date = $lower_part.datepicker('getDate')
	$upper_date = $upper_part.datepicker('getDate')
	unless ($lower_date <= $upper_date)
		## Change the one that DIDN'T just change.
		if $lower_part.is(obj)
			unless isNaN($upper_part.datepicker('getDate'))
				$upper_part.datepicker('setDate', $lower_date)
		else
			unless isNaN($lower_part.datepicker('getDate'))
				$lower_part.datepicker('setDate', $upper_date)
		$upper_part.datepicker('setStartDate', $lower_date)

Date.prototype.mobile = ->
	return new Array(this.getFullYear(), this.getFullMonth() + 1, this.getDate()).join("-")

jQuery ($) ->
	DATEPICKER_OPTIONS = {
		autoclose: true,
		todayHighlight: true,
		language: I18n.locale,
		format: I18n.t('date.formats.javascript', {defaultValue: "mm-dd-yyyy"})
	};
	parseDate = $.fn.datepicker.DPGlobal.parseDate

	jQuery('[data-behaviour="date-picker"]').datepicker(DATEPICKER_OPTIONS)
	## Mobile adds the question of weather or not to datepick.
	jQuery('[data-behaviour="date-picker-mobile"]').each (c,obj) ->
		$obj = jQuery(obj)
		if !Modernizr.inputtypes.date ## Browser doesn't support date inputs.
			$obj.datepicker(DATEPICKER_OPTIONS)
		else
			## Make sure it is of type date.
			$obj.attr('type', 'date')
	## Pick up clicks on the calendar icon, too.
	jQuery('[data-behaviour="date-picker"]').each (c,obj) ->
		$obj = jQuery(obj)
		jQuery('span.form-control-feedback', $obj.closest('div')).click (e,o) ->
			$obj.datepicker('show')
	jQuery('input[data-behaviour="date-picker"]', jQuery('[data-behaviour="date-range"]')).each (c,obj) ->
		jQuery(obj).change (e,o) ->
			check_daterange(this)
		check_daterange(this)
	jQuery('input[data-constrain-start-date]').each (c,obj) ->
		jQuery(obj).datepicker('setStartDate', jQuery(obj).attr('data-constrain-start-date'))
	jQuery('input[data-constrain-end-date]').each (c,obj) ->
		jQuery(obj).datepicker('setEndDate', jQuery(obj).attr('data-constrain-end-date'))