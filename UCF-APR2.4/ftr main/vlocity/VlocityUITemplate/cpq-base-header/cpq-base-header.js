vlocity.cardframework.registerModule.controller('cpqBaseHeaderCtrl', ['$scope', function($scope) {

 $scope.$on('vlocity.cpq.totalbar.reload', function(event, validation) {
                    console.log('vlocity.cpq.totalbar.reload from header base ')
    });

}]);