vlocity.cardframework.registerModule.controller('vlcSelectRCController', ['$scope', function ($scope) {
    debugger
    $scope.dateError=false;
    const currentDate = new Date();
    const newday = new Date();
    newday.setDate(currentDate.getDate() + 1);
    var tomorrow = newday.toISOString().split('T')[0];
    $scope.bpTree.response.mindate =tomorrow;
}]);