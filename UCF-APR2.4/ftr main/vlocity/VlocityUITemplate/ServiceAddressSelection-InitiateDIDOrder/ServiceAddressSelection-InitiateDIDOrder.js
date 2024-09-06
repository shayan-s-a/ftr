vlocity.cardframework.registerModule.controller('ServiceAddressSelectionController', ['$scope', '$window', function ($scope, $window) {
 
  $scope.isLoading = false;
  $scope.didForSubmission = false;
  $scope.minDueDate = new Date();
  $scope.bpTree.response.didForSubmission = false;



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
  
  $scope.$watch('bpTree.response.ServiceLocationDetails.Select1', function(newValue, oldValue) {
    console.log($scope.bpTree.response.ServiceLocationDetails.Select1)
  });

  $scope.$watch('bpTree.response.SelectServiceLocation.CurrentLocationId', function(newValue, oldValue) {
    if (newValue != oldValue) {
      console.log(newValue);
    }
  });

  $scope.showConfirmButton = function() {
    $scope.bpTree.response.didForSubmission = false;
        for (let i=0; i < $scope.bpTree.response.ServiceAccounts.length; i++) {
            
            if ($scope.bpTree.response.ServiceAccounts[i].DIDLocations.length > 0) {
                
                for (let j=0; j < $scope.bpTree.response.ServiceAccounts[i].DIDLocations.length; j++) {
                    // validation 1 All DID are already submitted
                    // validation 2 Same Due date is true but all the DidsDueDate are empty
                    // validation 3 All DID Location need to have DID Number validated true
                    if(!$scope.bpTree.response.ServiceAccounts[i].DIDLocations[j].isSubmitted__c && $scope.bpTree.response.ServiceAccounts[i].SameDuedate && $scope.bpTree.response.ServiceAccounts[i].DidsDueDate != null && $scope.bpTree.response.ServiceAccounts[i].DIDValidated){
                        $scope.bpTree.response.didForSubmission = true;
                        
                    } else if(!$scope.bpTree.response.ServiceAccounts[i].DIDLocations[j].isSubmitted__c && !$scope.bpTree.response.ServiceAccounts[i].SameDuedate && $scope.bpTree.response.ServiceAccounts[i].DIDLocations[j].DueDate__c != null && $scope.bpTree.response.ServiceAccounts[i].DIDLocations[j].isDIDNumberValidated__c ) {
                        $scope.bpTree.response.didForSubmission = true;
                    }


                }

            }
        }
  }

  $scope.initTemplate = function() {
    console.log("initTemplate", $scope.bpTree.response.ServiceAccounts);
      for (let i=0; i < $scope.bpTree.response.ServiceAccounts.length; i++) {
        $scope.bpTree.response.ServiceAccounts[i].currentLocationIndex = i;
        $scope.bpTree.response.ServiceAccounts[i].disableSameDueDate = false;

        if ($scope.bpTree.response.ServiceAccounts[i].DIDLocations == null) {
          $scope.bpTree.response.ServiceAccounts[i].DIDLocations = [];
        } else {
          
          for (let j=0; j < $scope.bpTree.response.ServiceAccounts[i].DIDLocations.length; j++) {
            if(!$scope.bpTree.response.ServiceAccounts[i].DIDLocations[j].isSubmitted__c){
              $scope.didForSubmission = true;
              $scope.bpTree.response.ServiceAccounts[i].DidsDueDate = null;

            } else {
              $scope.bpTree.response.ServiceAccounts[i].disableSameDueDate = true;
            }

            
          }

        }

        $scope.bpTree.response.ServiceAccounts[i].SameDueDate = !$scope.bpTree.response.ServiceAccounts[i].disableSameDueDate;
        
      }
  }
  $scope.openDIDNumberView = function(test) {
    
        let url = $scope.bpTree.response.sfdcIFrameOrigin.replaceAll('vlocity-cmt', 'c');
        if (test)
            $window.open(url + '/apex/DIDNumberView?didLocationId=' + $scope.bpTree.response.DIDSelection.Id, '_blank');
        else
            $window.open(url + '/lightning/r/'+ $scope.bpTree.response.DIDSelection.Id +'/related/DID_Number_Details__r/view', '_blank');
    }

  $scope.assingSameDueDateAllDID = function(index, recordId) {

    let dueDate = $scope.bpTree.response.ServiceAccounts[index].SameDueDate ? $scope.bpTree.response.ServiceAccounts[index].DidsDueDate : $scope.bpTree.response.ServiceAccounts[index].DidsDueDate = null; null;
    $scope.bpTree.response.ServiceAccounts[index].DIDValidated = ($scope.bpTree.response.ServiceAccounts[index].SameDueDate && $scope.bpTree.response.ServiceAccounts[index].DidsDueDate && $scope.bpTree.response.ServiceAccounts[index].DIDValidated) ? $scope.bpTree.response.ServiceAccounts[index].DIDValidated : false; 
  
    $scope.assingValidatedAllDID(index, recordId);
    if ($scope.bpTree.response.ServiceAccounts[index].DIDLocations !== null && $scope.bpTree.response.ServiceAccounts[index].DIDLocations.length > 0) {
      if($scope.bpTree.response.ServiceAccounts[index].Id == recordId) {
        for (let i=0; i < $scope.bpTree.response.ServiceAccounts[index].DIDLocations.length; i++) {
          if(!$scope.bpTree.response.ServiceAccounts[index].DIDLocations[i].isSubmitted__c){
            $scope.bpTree.response.ServiceAccounts[index].DIDLocations[i].DueDate__c = dueDate;
          }
        }
      }
    }

  }
  

  $scope.assingValidatedAllDID = function(index, recordId) {

    let DIDValidated = $scope.bpTree.response.ServiceAccounts[index].DIDValidated ? $scope.bpTree.response.ServiceAccounts[index].DIDValidated : false;

    if ($scope.bpTree.response.ServiceAccounts[index].DIDLocations !== null && $scope.bpTree.response.ServiceAccounts[index].DIDLocations.length > 0) {
      if($scope.bpTree.response.ServiceAccounts[index].Id == recordId) {
        for (let i=0; i < $scope.bpTree.response.ServiceAccounts[index].DIDLocations.length; i++) {
          if(!$scope.bpTree.response.ServiceAccounts[index].DIDLocations[i].isSubmitted__c){
            $scope.bpTree.response.ServiceAccounts[index].DIDLocations[i].isDIDNumberValidated__c = DIDValidated;
          }
        }
      }
    }

  }

  $scope.validateIsSubmitted = function(index, parentIndex) {

        if($scope.bpTree.response.ServiceAccounts[parentIndex].DIDLocations[index].isSubmitted__c){
          $scope.bpTree.response.ServiceAccounts[parentIndex].DIDLocations[index].isSubmitted__c = true;
        } else {
          $scope.bpTree.response.ServiceAccounts[parentIndex].DIDLocations[index].isSubmitted__c = false;
          
        }
      
      return false;

  }

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