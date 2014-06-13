// homeIndex.js

var module = angular.module("homeIndex", ['ngRoute']);

module.controller('topicsController', function ($scope, $http, dataService) {
    $scope.isBusy = false;
    $scope.data = dataService;
    if (dataService.isReady() == false) {
        $scope.isBusy = true;
        dataService.getTopics().then(
            function () {
                // success
            }, function () {
                // failure
                alert("Could not load topics.");
            }
        ).then(
            function () {
                $scope.isBusy = false;
            }
        );
    }
});
module.controller('newTopicController', function ($scope, $http, $window, dataService) {
    $scope.newTopic = {};
    $scope.save = function () {
        dataService.addTopic($scope.newTopic).then(
            function (newTopic) {
                // success.
                console.log(newTopic);
                $window.location = "#/";
            }, function (error) {
                // failure.
                alert("Unable to save new topic.");
            }
        );
    }
});

module.factory("dataService", function ($http, $q) {
    var _topics = [];
    var _isInitialized = false;
    var _isReady = function () {
        return _isInitialized;
    }
    var _getTopics = function () {
        var deferred = $q.defer();
        $http.get("/api/v1/topics/?includeReplies=true").then(
            function (result) {
                // Success.
                angular.copy(result.data, _topics);
                _isInitialized = true;
                deferred.resolve(result);
            }, function (data) {
                console.log(data);
                deferred.reject(data);
            }
        );
        return deferred.promise;
    };
    var _addTopic = function (newTopic) {
        var deferred = $q.defer();
        $http.post(
            "/api/v1/topics",
            newTopic
        ).then(
            function (result) {
                // success
                _topics.splice(0, 0, result.data);
                deferred.resolve(result.data); // Return the new topic.
            }, function (error) {
                // failure.
                deferred.reject(error);
            }
        );
        return deferred.promise;
    };
    return {
        topics: _topics,
        getTopics: _getTopics,
        addTopic: _addTopic,
        isReady: _isReady
    };
});

module.config(function ($routeProvider) {
    $routeProvider.when("/", {
        controller: "topicsController",
        templateUrl: "/templates/topicsView.html"
    });
    $routeProvider.when("/newmessage", {
        controller: "newTopicController",
        templateUrl: "/templates/newTopicView.html"
    });
    $routeProvider.otherwise({ redirectTo: "/" });
});
