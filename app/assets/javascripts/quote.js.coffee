# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

## Utility functions.
String.format = (input) ->
	for arg in arguments
		reg = new RegExp("\\{" + _i + "\\}", "gm");
		input = input.replace(reg, arg);
	return input
Array::where = (query) ->
    return [] if typeof query isnt "object"
    hit = Object.keys(query).length
    @filter (item) ->
        match = 0
        for key, val of query
            match += 1 if item[key] is val
        if match is hit then true else false

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
	$scope.dl_quote = false
	$scope.initialize = ->
		$http.get($scope.getUrl('towed')).success (data) ->
			angular.copy data.vehicle_types, $scope.towed_unit_types if data.vehicle_types
		$scope.update()
	$scope.update = ->
		$http.get($scope.getUrl()).success (data) ->
			angular.copy data.vehicle_types, $scope.vehicle_types if data.vehicle_types
			angular.copy data.makes, $scope.makes if data.makes
			if data.models
				angular.copy data.models, $scope.models
				$scope.has_models = ($scope.models.length != 0)
			angular.copy data.body_styles, $scope.body_styles if data.body_styles
			if data.vehicle_types && !$scope.vehicle_type &&
					$('#quote_vehicle_type').attr('data-default')
				$scope.vehicle_type = data.vehicle_types.where(
					id:parseInt($('#quote_vehicle_type').attr('data-default'))
				)[0]
				$('#quote_vehicle_type').attr('data-default', '')
				$scope.update()
			if data.makes && !$scope.make && 
					$('#quote_make_id').attr('data-default')
				$scope.make = data.makes.where(
					id:parseInt($('#quote_make_id').attr('data-default'))
				)[0]
				$('#quote_make_id').attr('data-default', '')
				$scope.update()
			if data.models && !$scope.model &&
					$('#quote_model_id').attr('data-default')
				$scope.model = data.models.where(
					id:parseInt($('#quote_model_id').attr('data-default'))
				)[0]
				$('#quote_model_id').attr('data-default', '')
				$scope.update()
	$scope.updateVehicleType = ->
		$scope.dl_quote = ($scope.vehicle_type && $scope.vehicle_type.id == 22)
		$scope.make = ""
		$scope.makes = []
		$scope.model = ""
		$scope.models = []
		$scope.body_style = ""
		$scope.body_styles = []
		$scope.update()
	$scope.updateMake = ->
		$scope.model = ""
		$scope.models = []
		$scope.body_style = ""
		$scope.body_styles = []
		$scope.update()
	$scope.getUrl = (type="power") ->
		api_url = [ String.format("/api/vehicles/{1}", type) ]
		api_url.push(this.vehicle_type.id) if this.vehicle_type
		api_url.push(this.make.id) if this.make
		api_url.push(this.model.id) if this.model
		api_url.join '/'
	$scope.hasError = (key) ->
		return $(key).length > 0
	$scope.getError = (key) ->
		console.log(key)
		return $(key).html()
	$scope.initialize()