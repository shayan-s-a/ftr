vlocity.cardframework.registerModule.controller('vlcSelectUNIController', ['$scope', function($scope) {
// Your code goes here
    $scope.initSelectUNIs = function(index) {
        for (let i = 0; i < $scope.bpTree.response.SelectUNIs.length; i++) {
            if (Array.isArray($scope.bpTree.response.EVCUNIAssoc.EVC)) {
                var preSelectedUNI = $scope.bpTree.response.EVCUNIAssociations.EVC[index]["selected" + $scope.control.name];
            } else {
                var preSelectedUNI = $scope.bpTree.response.EVCUNIAssociations.EVC["selected" + $scope.control.name];
            }
            if (preSelectedUNI && preSelectedUNI.Id === $scope.bpTree.response.SelectUNIs[i].Value.Id) {
                if (!$scope.bpTree.response.EVCUNIAssoc.EVC[$scope.child.blockIndex]) {
                    $scope.bpTree.response.EVCUNIAssoc.EVC[$scope.child.blockIndex] = {};
                }
                $scope.bpTree.response.EVCUNIAssoc.EVC[$scope.child.blockIndex]["selected" + $scope.control.name] = $scope.bpTree.response.SelectUNIs[i].Value;
                if (!Array.isArray($scope.bpTree.response.EVCUNIAssoc.EVC)){
                    $scope.bpTree.response.EVCUNIAssoc.EVC["selected" + $scope.control.name] = $scope.bpTree.response.SelectUNIs[i].Value;
                } 

            }
        }
    }

    $scope.updateEVC = function() {
        if (!Array.isArray($scope.bpTree.response.EVCUNIAssoc.EVC)){
            $scope.bpTree.response.EVCUNIAssoc.EVC["selected" + $scope.control.name] = $scope.bpTree.response.EVCUNIAssoc.EVC[$scope.child.blockIndex]["selected" + $scope.control.name];
        }
    }

}]);