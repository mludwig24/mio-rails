# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

## Utility functions.
String.format = (input) ->
	for arg in arguments
		reg = new RegExp("\\{" + _i + "\\}", "gm");
		input = input.replace(reg, arg);
	return input


## Setup the basic app for filters and such.
window.mioApp = angular.module 'mioApp', []
mioApp.filter 'range', ->
	return (input, total) ->
		total = parseInt total
		return [] if total == 0 ## Not doing anything.
		(i for i in [1..total])
mioApp.filter 'format', ->
	return String.format

mioApp.controller 'MakeModelController', ($scope, $http) ->
	$scope.vehicle_types ?= []
	$scope.makes ?= []
	$scope.models ?= []
	$scope.body_styles ?= []
	$scope.towed_unit_types ?= []
	$scope.has_models = true
	$scope.towed_units = 0 ## Default to not towing.
	$scope.initialize = ->
		$http.get($scope.getUrl('towed')).success (data) ->
			console.log(data.vehicle_types)
			angular.copy data.vehicle_types, $scope.towed_unit_types if data.vehicle_types
		$scope.update()
	$scope.update = ->
		$http.get($scope.getUrl()).success (data) ->
			angular.copy data.vehicle_types, $scope.vehicle_types if data.vehicle_types
			angular.copy data.makes, $scope.makes if data.makes
			if data.models
				angular.copy data.models, $scope.models
				if $scope.models.length == 0
					$scope.has_models = false
				else
					$scope.has_models = true
			angular.copy data.body_styles, $scope.body_styles if data.body_styles
	$scope.updateVehicleType = ->
		$scope.make = ""
		$scope.model = ""
		$scope.body_style = ""
		$scope.update()
	$scope.updateMake = ->
		$scope.model = ""
		$scope.body_style = ""
		$scope.update()
	$scope.getUrl = (type="power") ->
		api_url = [ String.format("/api/vehicles/{1}", type) ]
		api_url.push(this.vehicle_type.id) if this.vehicle_type
		api_url.push(this.make.id) if this.make
		api_url.push(this.model.id) if this.model
		api_url.join '/'
	$scope.updateTowedUnits = ->
		console.log "updateTowedUnits"
	$scope.initialize()