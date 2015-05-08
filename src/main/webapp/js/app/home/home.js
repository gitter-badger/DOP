'use strict';

angular.module('dop.home', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/', {
    templateUrl: 'js/app/home/home.html',
    controller: 'HomeController'
  });
}])

.controller('HomeController', ["$scope", function( $scope ) {
	$scope.message = "Hello World";
}]);