vlocity.cardframework.registerModule.controller('ServiceAddressSelectionController', ['$scope', function ($scope) {
  $scope.isLoading = false;

  $scope.$watch('bpTree.response.SelectedLocations', function(newValue, oldValue) {
    if (newValue != oldValue) {
      if ($scope.bpTree.response.QuestionnaireData) {
        mergeServiceLocationWithQuestionnaireByLocationId(newValue, $scope.bpTree.response.QuestionnaireData);
      }
      setElementData('SelectServiceLocation:PrimaryLocationId', getPrimaryLocation());
      setElementData('SelectServiceLocation:CountOfLocations', $scope.bpTree.response.SelectedLocations.length);
      if (getPrimaryLocation() != null)
        $scope.bpTree.response.CurrentLocationId = getPrimaryLocation();
      if ($scope.bpTree.response.SelectedLocations.length == 1) {
        $scope.bpTree.response.CurrentLocationId = $scope.bpTree.response.SelectedLocations[0].Id;
        $scope.setPrimaryLocation($scope.bpTree.response.SelectedLocations[0].Id);
      }
    }
  });

  $scope.$watch('bpTree.response.CurrentLocationId', function(newValue, oldValue) {
    if (newValue != oldValue) {
      for (let i=0; i < $scope.bpTree.response.SelectedLocationsMerged.length; i++) {
        if ($scope.bpTree.response.SelectedLocationsMerged[i].Id == $scope.bpTree.response.CurrentLocationId) {
          setElementData('SelectServiceLocation:CurrentLocationId', $scope.bpTree.response.SelectedLocationsMerged[i].Id);
          setElementData('SelectServiceLocation.CurrentLocationName', $scope.bpTree.response.SelectedLocationsMerged[i].ShippingStreet + ' ' + $scope.bpTree.response.SelectedLocationsMerged[i].ShippingCity + ', ' + $scope.bpTree.response.SelectedLocationsMerged[i].ShippingState + ' ' + $scope.bpTree.response.SelectedLocationsMerged[i].ShippingPostalCode);
          
          // Setting values to all the questionnaire form
          // Questionnaire ID
          $scope.bpTree.response.QuestionnarieId = $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.Id : '';

          // Location
          setElementData('SelectServiceLocation:LocationDetails:DownstreamBandwidth', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? parseInt($scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.DownstreamBandwidthMbs) : '');
          setElementData('SelectServiceLocation:LocationDetails:UpstreamBandwidth', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? parseInt($scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.UpstreamBandwidthMbs) : '');
          setElementData('SelectServiceLocation:LocationDetails:DHCPServer', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.DHCPServer : '');
          
          // Licenses Questions
          setElementData('LicSelection:LicensingQuestions:ExternalPagingFaxAvailability', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.ExternalPagingFaxAvailability : '');
          setElementData('LicSelection:LicensingQuestions:AnalogDevicesAttachedtoPortedNumbers', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.AnalogDevicesAttachedPortedNumbers : '');
          
          // Addons Questions
          setElementData('AddOnSelection:AddOnQuestions:TollFreeServicesRequired', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.TollFreeServicesReq : '');
          setElementData('AddOnSelection:AddOnQuestions:MultipleAutoAttendantsRequirement', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.MultipleAutoAttendantsReq : '');

          // Accessory Questions
          setElementData('AccessorySelection:AccessoriesQuestions:PhonePowerSource', $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData ? $scope.bpTree.response.SelectedLocationsMerged[i].questionnaireData.PhonePowerSource : '');
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

  function mergeServiceLocationWithQuestionnaireByLocationId(serviceLocations, questionnaireData) {
    for (let i=0; i < questionnaireData.length; i++) {

      for (let j=0; j < serviceLocations.length; j++) {
        if (serviceLocations[j].Id == questionnaireData[i].ServiceLocationId) {
          serviceLocations[j].questionnaireData = questionnaireData[i];
          break;
        }
      }
    }
    $scope.bpTree.response.SelectedLocationsMerged = serviceLocations;
  }

}])