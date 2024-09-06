vlocity.cardframework.registerModule.controller('ServiceAddressSelectionControllerSIP', ['$scope', function ($scope) {
  $scope.isLoading = false;

  $scope.$watch('bpTree.response.SelectedLocations', function(newValue, oldValue) {
    if (newValue != oldValue) {
      setElementData('SelectServiceLocation:PrimaryLocationId', getPrimaryLocation());
      setElementData('CountOfLocations', $scope.bpTree.response.SelectedLocations.length);
      if (getPrimaryLocation() != null)
        $scope.bpTree.response.CurrentLocationId = getPrimaryLocation();
      if ($scope.bpTree.response.SelectedLocations.length == 1) {
        setElementData('SelectServiceLocation:CurrentLocationId', $scope.bpTree.response.SelectedLocations[0].Id);
        setElementData('SelectServiceLocation:CurrentLocationLit', $scope.bpTree.response.SelectedLocations[0].Premises.Fiber_Tier__c == 'Tier 0' ? true : false);
        setElementData('SelectServiceLocation:CurrentLocationName', $scope.bpTree.response.SelectedLocations[0].ShippingStreet + ' ' + $scope.bpTree.response.SelectedLocations[0].ShippingCity + ', ' + $scope.bpTree.response.SelectedLocations[0].ShippingState + ' ' + $scope.bpTree.response.SelectedLocations[0].ShippingPostalCode);
        $scope.setPrimaryLocation($scope.bpTree.response.SelectedLocations[0].Id);
      }
    }
  });

  $scope.$watch('bpTree.response.SelectServiceLocation.CurrentLocationId', function(newValue, oldValue) {
    if (newValue != oldValue) {
      for (let i=0; i < $scope.bpTree.response.SelectedLocations.length; i++) {
        if ($scope.bpTree.response.SelectedLocations[i].Id == $scope.bpTree.response.SelectServiceLocation.CurrentLocationId) {
          setElementData('SelectServiceLocation:CurrentLocationId', $scope.bpTree.response.SelectedLocations[i].Id);
          setElementData('SelectServiceLocation:CurrentLocationLit', $scope.bpTree.response.SelectedLocations[i].Premises.Fiber_Tier__c == 'Tier 0' ? true : false);
          setElementData('SelectServiceLocation:CurrentLocationName', $scope.bpTree.response.SelectedLocations[i].ShippingStreet + ' ' + $scope.bpTree.response.SelectedLocations[i].ShippingCity + ', ' + $scope.bpTree.response.SelectedLocations[i].ShippingState + ' ' + $scope.bpTree.response.SelectedLocations[i].ShippingPostalCode);
          if($scope.bpTree.response.isBundle){ //if 
          let osDatas = $scope.bpTree.response.OSData;
          if (Array.isArray(osDatas)) {
            angular.forEach(osDatas, function(data){
              if(data.ServiceAccountId == newValue){
                setElementData('Promotion', data);
              }

          });
          } else {
                setElementData('Promotion', osDatas);
          }



          }
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

  $scope.setPrimaryLocation = function (locationId) {
    for (let i=0; i < $scope.bpTree.response.SelectedLocations.length; i++) {
      if ($scope.bpTree.response.SelectedLocations[i].Id == locationId)
        $scope.bpTree.response.SelectedLocations[i].isPrimary = true;
      else
        $scope.bpTree.response.SelectedLocations[i].isPrimary = false;
    }
    setElementData('SelectServiceLocation:PrimaryLocationId', locationId);
  }

  function getPrimaryLocation () {
    for (let i=0; i < $scope.bpTree.response.SelectedLocations.length; i++) {
      if ($scope.bpTree.response.SelectedLocations[i].isPrimary) {
        return $scope.bpTree.response.SelectedLocations[i].Id;
      }
    }
    return null;
  }


}])