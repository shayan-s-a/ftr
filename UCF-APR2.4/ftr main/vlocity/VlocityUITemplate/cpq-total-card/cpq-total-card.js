vlocity.cardframework.registerModule.controller('cpqTotalCardController', ['$scope', '$rootScope', function($scope, $rootScope) {
    console.log("inside cpqTotalCardController")
    $scope.$on('vlocity.cpq.totalbar.reload', function(event, validation) {
                    console.log('vlocity.cpq.totalbar.reload from total card')
                    $rootScope.$broadcast('vlocity.cpq.header.reload');
                }
    )
}]);