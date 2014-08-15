# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.mioApp = angular.module 'mioApp', [] unless window.mioApp

mioApp.controller 'AppController', ($scope, $http) ->
	$scope.initialize = ->
	console.log "Moo"