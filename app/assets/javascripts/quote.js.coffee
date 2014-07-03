# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.MakeModelController = ($scope, $http) ->
	$scope.vehicle_types ?= []
	$scope.makes ?= []
	$scope.models ?= []
	$scope.body_styles ?= []
	$scope.update = ->
		$http.get($scope.getUrl()).success (data) ->
			angular.copy data.vehicle_types, $scope.vehicle_types if data.vehicle_types
			angular.copy data.makes, $scope.makes if data.makes
			angular.copy data.models, $scope.models if data.models
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
	$scope.getUrl = ->
		api_url = [ "/api/vehicles/power" ]
		api_url.push(this.vehicle_type.id) if this.vehicle_type
		api_url.push(this.make.id) if this.make
		api_url.push(this.model.id) if this.model
		api_url.join '/'
	$scope.update()