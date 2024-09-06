baseCtrl.prototype.$scope.consoleLog = function(e) {
    console.log(e);
}

vlocity.cardframework.registerModule.controller('customBlockController', ['$scope','$rootScope','$timeout', function($scope, $rootScope, $timeout) {

    $rootScope.$on("ClearRepeatableBlock", function(evt, name){ 
        $timeout(function(){
            if ($scope.child.eleArray[0].name == name) {
                $scope.child.eleArray.length = 1;
            }
        }, 0);
    });
    
    $scope.deleteFromDatabase = function(ele, child, index) {
        try {
            let elementName = child.eleArray[index].name;

            if (elementName == 'UNIDetails') {

                setElementValue('UNIsToDelete', child.eleArray[index].children[0].response);
                setElementValue('UNIDetailsToDelete', child.eleArray[index].children[1].response);
                jQuery(function() {
                    if ($scope.bpTree.response.UNIDetailsToDelete != null)
                        $('#DeleteUNIDetails').click();
                    if ($scope.bpTree.response.UNIsToDelete != null)
                        $('#DeleteUNIs').click();
                });

            } else if (elementName == 'ELINERL') {
                setElementValue('IdToDelete', child.eleArray[index].children[0].response);
                jQuery(function() {
                    if ($scope.bpTree.response.IdToDelete != null)
                        $('#DeleteELINERL').click();
                });
            }
            

        } catch (err) {
            console.error(err);
        }
    }

    $scope.clearIdField = function (child, index) {

        let elementName = child.eleArray[index].name;

        if (elementName == 'UNIDetails') {
            child.eleArray[index].children[0].eleArray[0].response = null;
            child.eleArray[index].children[1].eleArray[0].response = null;
            
        } else if (elementName == 'ELINERL') {
            child.eleArray[index].children[0].eleArray[0].response = null;
            
        }
    }

    function setElementValue (name, value) {
        var toSet = value;
        // Accept either colons or periods as path seperators
        let namePath = name.split(/[:\.]/);

        for (var i = namePath.length - 1; i >= 0; i--) {
            var newSet = {};
            newSet[namePath[i]] = toSet;
            toSet = newSet;
        }

        baseCtrl.prototype.$scope.applyCallResp(toSet);
    }

}]);