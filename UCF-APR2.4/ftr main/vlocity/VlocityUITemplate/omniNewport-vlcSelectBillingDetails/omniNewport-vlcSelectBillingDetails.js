vlocity.cardframework.registerModule.controller('selectBillingDetailsCtrl', ['$scope','$timeout', function($scope, $timeout) {

    $scope.options = [];
    $scope.selectedItem = {};
    $scope.dpiEnv;
    const nullItem = {
        name: '', 
        value: '', 
        BillingTelephoneNumber__c: '', 
        BillingCycle__c: '', 
        DPIBillingDetailsId: '', 
        GlobalAccountNumber__c: '', 
        MasterSummaryNumber__c: ''
    };
    $scope.$watch('bpTree.response.DPIBillingDetailList', function(newVal,oldVal) {
        if (newVal != null && newVal != oldVal) {
            $timeout(function() {
                $scope.dpiEnv = $scope.$parent.$parent.$parent.children[$scope.$parent.$parent.$parent.children.length-1].response; // DPIEnviornment element is the last one in this block
                console.log('DPIBillingDetailList',$scope.bpTree.response.DPIBillingDetailList);
                if ($scope.dpiEnv == null) {
                    $scope.options = [];
                } else {
                    $scope.options = angular.copy($scope.bpTree.response.DPIBillingDetailList[$scope.dpiEnv]);
                    $scope.options = $scope.options.sort((a, b) => (parseInt(a.BillingTelephoneNumber__c) > parseInt(b.BillingTelephoneNumber__c)) ? 1 : -1);
                }
                for (let i=0; i < $scope.options.length; i++) {
                    $scope.options[i].DPIBillingDetailsId = $scope.options[i].Id;
                    $scope.options[i].name = $scope.options[i].BillingTelephoneNumber__c;
                    $scope.options[i].value = $scope.options[i].BillingTelephoneNumber__c;
                    setValue($scope.options[i]);
                }
                $scope.options.unshift(nullItem);
            });
        }
    });

    function setValue(option) {
        for (let i=0; i < $scope.$parent.children.length; i++) {
            if (option.DPIBillingDetailsId == $scope.$parent.children[i].response) {
                $scope.itemSelected(option);
            }
        }
    }

    $scope.itemSelected = function (item) {
        $scope.selectedItem = null;
        $scope.selectedItem = item;
        for (let i=0; i < $scope.$parent.children.length; i++) {
            for (var key in $scope.selectedItem) {
                if ($scope.$parent.children[i].eleArray[0].name == key) {
                    console.log(key + " -> " + $scope.selectedItem[key]);
                    $scope.$parent.children[i].eleArray[0].response = $scope.selectedItem[key];
                }
            }
        }
    }

}]);