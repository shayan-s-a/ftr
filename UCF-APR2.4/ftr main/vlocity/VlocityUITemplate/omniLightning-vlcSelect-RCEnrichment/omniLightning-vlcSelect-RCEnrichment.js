vlocity.cardframework.registerModule.controller('vlcSelectRCController', ['$scope', function ($scope) {

    $scope.setElementData = function (name, value) {
        var toSet = value;
        // Accept either colons or periods as path seperators
        let namePath = name.split(/[:\.]/);
        for (var i = namePath.length - 1; i >= 0; i--) {
            var newSet = {};
            newSet[namePath[i]] = toSet;
            toSet = newSet;
        }
        console.log(toSet);
        baseCtrl.prototype.$scope.applyCallResp(toSet);
    };

}]);