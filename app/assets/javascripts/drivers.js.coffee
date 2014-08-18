# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.mioApp = angular.module 'mioApp', [] unless window.mioApp

mioApp.controller 'DriverController', ($scope, $http) ->
	$scope.errors = []
	$scope.add_driver = ->
		form = $('#add_driver form')
		$scope.errors = []
		$.post(form.attr('action'), $(form).serialize()).success (data) ->
			$scope.$emit('new_driver', data)
			$('#add_driver').modal('hide')
			$('#add_driver input').val('')
			$scope.errors = []
		.error (xhr, data) ->
			$scope.errors.push {"key": I18n.t('activerecord.attributes.driver.' + key), "errors": errors} for key, errors of JSON.parse(xhr.responseText)['errors']
			$scope.$apply()