# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.mioApp = angular.module 'mioApp', [] unless window.mioApp

mioApp.controller 'PersonalController', ($scope, $http) ->
	$scope.drivers = []
	$scope.$on 'new_driver', (e, driver) ->
		$scope.drivers.push(driver)
		$scope.getDrivers()
	$scope.getDrivers = ->
		$scope.drivers = []
		$http.get($('#app_personal > form').attr('action') + '/drivers/').success (data) ->
			for driver in data
				if $('#ng-prepopulate > [data-name="driver[' + driver.id + '][first_name]"]').length > 0
					driver.first_name = $('#ng-prepopulate > [data-name="driver[' + driver.id + '][first_name]"]').attr('data-value')
					driver.last_name = $('#ng-prepopulate > [data-name="driver[' + driver.id + '][last_name]"]').attr('data-value')
				$scope.drivers.push(driver)
			if !$scope.$$phase
  				$scope.$apply
	$scope.getDrivers()

mioApp.controller 'VehicleFormController', ($scope, $http) ->
	$scope.financed_ownership = ->
		$.inArray($scope.ownership, ["financed", "leased"]) >= 0
	# pass.