vlocity.cardframework.registerModule.controller('ServiceAddressSelectionController', ['$scope', function ($scope) {
  $scope.isLoading = false;

  $scope.$watch('bpTree.response.ServiceAccounts', function(newValue, oldValue) {
    if (newValue != oldValue) {
      if ($scope.bpTree.response.CurrentDIDLocationCount == null) {
        setElementData('SelectServiceLocation:CurrentLocationId', newValue[0].Id);
        setElementData('SelectServiceLocation:CurrentLocationName',newValue[0].Name);
        newValue[0].currentLocationIndex = 0;
        setElementData('CurrentServiceLocation', newValue[0]);
      }
      setElementData('SelectServiceLocation:CountOfLocations', newValue.length);
      if (newValue[$scope.bpTree.response.CurrentServiceLocation.currentLocationIndex].DIDLocations == null) {
        newValue[$scope.bpTree.response.CurrentServiceLocation.currentLocationIndex].DIDLocations = [];
      }
      setElementData('CurrentServiceLocation', newValue[$scope.bpTree.response.CurrentServiceLocation.currentLocationIndex]);
    }
  });

  $scope.$watch('bpTree.response.SelectServiceLocation.CurrentLocationId', function(newValue, oldValue) {
    if (newValue != oldValue) {
      console.log(newValue);
      for (let i=0; i < $scope.bpTree.response.ServiceAccounts.length; i++) {
        if ($scope.bpTree.response.ServiceAccounts[i].Id == newValue) {
          setElementData('SelectServiceLocation:CurrentLocationName',$scope.bpTree.response.ServiceAccounts[i].Name);
          setElementData('SelectServiceLocation:CurrentLocationId', $scope.bpTree.response.ServiceAccounts[i].Id);
          $scope.bpTree.response.ServiceAccounts[i].currentLocationIndex = i;
          if ($scope.bpTree.response.ServiceAccounts[i].DIDLocations == null) {
            $scope.bpTree.response.ServiceAccounts[i].DIDLocations = [];
          }
          setElementData('CurrentServiceLocation', $scope.bpTree.response.ServiceAccounts[i]);

          $scope.bpTree.response.DIDLocationNameToCompare = $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0] ? $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0].name : '';
          $scope.bpTree.response.DIDLocationIdForUpdate = $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0] ? $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0].value : '';
          setElementData('SelectServiceLocation:DIDLocationName', $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0] ? $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0].name : '');
          setElementData('SelectServiceLocation:isAddressInFootPrint', $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0] ? ''+$scope.bpTree.response.ServiceAccounts[i].DIDLocations[0].isAddressInFootPrint : '');
          setElementData('SelectServiceLocation:moreInfo', $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0] ? $scope.bpTree.response.ServiceAccounts[i].DIDLocations[0].ucfLocationDetails : '');
          // clear the dropdown
          setElementData('SelectServiceLocation:ExistingDIDLocations', null);
        }
      }
    }
  });

  function setElementData (name, value) {
    var toSet = value;
    // Accept either colons or periods as path seperators
    let namePath = name.split(/[:\.]/);

    for (var i = namePath.length - 1; i >= 0; i--) {
        var newSet = {};
        newSet[namePath[i]] = toSet;
        toSet = newSet;
    }

    baseCtrl.prototype.$scope.applyCallResp(toSet);
  };

}]);