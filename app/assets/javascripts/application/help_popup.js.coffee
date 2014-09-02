jQuery ->
	jQuery('.help_popup_modal').each (i, modal) ->
		$modal = jQuery(modal)
		help_for = $modal.attr('data-help_popup_for')
		jQuery('[for=' + help_for + ']').each (i2, label) ->
			$label = jQuery(label)
			a = jQuery('<a>').click (e) ->
				e.preventDefault()
				$modal.modal('show')
			a.attr "href", '#' + $modal.attr('id')
			a.html($label.html())
			$label.html(a)
