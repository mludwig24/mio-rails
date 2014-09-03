# This file handles the help-popup from javascript into the modal dialogs.
# Hopefully this saves load time for mobile browsers.

jQuery ($) ->
	$('.help-popup-content').each (i, modal) ->
		$modal = $(modal)
		unless $($modal.attr('data-help-popup-id')).length > 0
			$div = $('<div>', {id: $modal.attr('data-help-popup-id'), class: 'modal fade'})
			$div.append(
				$('<div>', {class: 'modal-dialog'}).append(
					$('<div>', {class: 'modal-content'}).append(
						$('<div>', {class: 'modal-header'}).append(
							$('<button>', {class: 'close'})
								.html '&times;'
								.attr 'data-dismiss', 'modal'
						).append(
							$('<h3>')
								.html $modal.attr('data-help-popup-title')
						)
					).append($('<div>', {class: 'modal-body'}).append(
						$('<p>')
							.html $modal.html()
						)
					).append(
						$('<div>', {class: 'modal-footer'}).append(
							$('<button>', {type: 'button', class: 'btn btn-primary'})
								.attr 'data-dismiss', 'modal'
								.html I18n.t('global.close')
							)
					)
				)
			)
			$('body').append $div
		help_for = $modal.attr('data-help-popup-for')
		$('[for=' + help_for + ']').each (i2, label) ->
			$label = $(label)
			a = $('<a>').click (e) ->
				e.preventDefault()
				$ '#' + $modal.attr 'data-help-popup-id'
					.modal('show')
			a.attr "href", '#' + $modal.attr('data-help-popup-id')
			a.html($label.html())
			$label.html(a)
