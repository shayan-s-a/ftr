vlocity.cardframework.registerModule.controller('customerInfoController', ['$scope', '$route', function ($scope, $route) {

  $scope.bpTree.response.IsCheckboxChecked = true

  // define arrays for use in this template
  $scope.locationsTableArray = []
  var selectedLocations = $scope.bpTree.response.SelectedLocations || [] // Values from Quote selectedLocations field

  function checkDSAT() {
    $scope.bpTree.response.IsCheckboxChecked = true
    if (Array.isArray(selectedLocations)) {
      var d = new Date()
      for (let i=0; i<selectedLocations.length; i++) {
        if (selectedLocations[i].Premises && selectedLocations[i].Premises.Last_DSAT_Check__c) {
          var getDate = selectedLocations[i].Premises.Last_DSAT_Check__c
          var now = new Date(getDate)
          now.setDate(now.getDate() + 30)
          if (now < d) {
            $scope.bpTree.response.IsCheckboxChecked = false
            break;
          }
        } else {
            $scope.bpTree.response.IsCheckboxChecked = false
            break;
        }
      }
    }
  }

  // function to merge selected Locations with service Accounts
  var mergeLocations = function () {
    var serviceAccounts = $scope.bpTree.response.ServiceAccounts || [] // Values from DR Extract of Service Accounts
    var finalData = []
    var checkflag = false
    // if selectedLocations has values, merge those with the full list of Service Accounts and show them as checked
    if (selectedLocations != null || selectedLocations !== undefined || selectedLocations !== '') {
      angular.forEach(serviceAccounts, function (serviceAcctData) {
        angular.forEach(selectedLocations, function (selectedLocData) {
          if (selectedLocData.Id === serviceAcctData.Id) {
            serviceAcctData.locationChecked = true
            checkflag = true
          }
        })
        if (checkflag === false) {
          serviceAcctData.locationChecked = false
        }
        finalData.push(serviceAcctData)
      })
      $scope.locationsTableArray = finalData
      selectedLocations = finalData.filter(acc => (acc.locationChecked))
      $scope.bpTree.response.SelectedLocations = selectedLocations;
      $scope.bpTree.response.ServiceAccountsUpdated = false
      checkDSAT();
    }

    else {
      $scope.locationsTableArray = $scope.bpTree.response.ServiceAccounts || []
      $scope.bpTree.response.ServiceAccountsUpdated = false

    }
    if (serviceAccounts.length === 0) {
      document.getElementById('DisplayServiceLocations_nextBtn').style.display = 'none'
      
      //document.getElementById('customNextBtn').style.display = 'none'
    }

  }

  $scope.init = function () {
    document.getElementById('customNextBtn').disabled = true;
    mergeLocations()
  }

  $scope.$watch('bpTree.response.ServiceAccountsUpdated', function () {
    if ($scope.bpTree.response.ServiceAccountsUpdated) {
      mergeLocations()
    }
  })

  $scope.$watch('bpTree.response.ServiceAccounts', function (newVal, oldVal) {
    if (newVal !== undefined && newVal.length > 0) {
      $('#DisplayServiceLocations_nextBtn').css('display', 'block')
     
    }
  })

  $scope.showTypeAheadBlock = function () {
    $scope.bpTree.response.showTypeAhead = true
  }
  $scope.hideTypeAheadBlock = function () {
    $scope.bpTree.response.showTypeAhead = false
  }

  $scope.sort = {
    column: '',
    descending: false
  };

  $scope.sortColumn = function (column) {

    var sort = $scope.sort;

    if (sort.column == column) {
      sort.descending = !sort.descending;
    } else {
      sort.column = column;
      sort.descending = false;
    }
  };

  $scope.selectedCls = function (column) {
    return column == $scope.sort.column && 'sort-' + $scope.sort.descending;
  };

  $scope.iconclick = function (record) {
    $scope.isLoading = true
    // Keeping Backup of this data which made by sean
    let contextId = $scope.bpTree.response.OpportunityId ? $scope.bpTree.response.OpportunityId : $scope.bpTree.response.ContextId
    var ipInput = {
      AQRecordId: 0,
      OpportunityId: '',
      Address: record.ShippingStreet,
      City: record.ShippingCity,
      State: record.ShippingState,
      ZipCode: record.ShippingPostalCode,
      BusinessName: record.Name,
      ParentAccountId: $scope.bpTree.response.ParentAccountId,
      ContextId: contextId,
      PremisesId: record.Premises ? record.Premises.Id : null
    }

    var option = {}
    $scope.bpService.GenericInvoke('RefreshDSATClass', 'getRefreshAPIDetails', angular.toJson(ipInput), angular.toJson(option)).then(function (result) {
      $scope.isLoading = false
      if (typeof result !== 'undefined') {
        var res = JSON.parse(result)
        console.log('Result of refresh:', res);
        if (res && res.IPResult) {
          if (res.IPResult.success || res.IPResult.ServiceAccountsUpdated) {
            if ($scope.bpTree.response.OpportunityId) {
              window.location.search += '&QuoteId=' + $scope.bpTree.response.QuoteId;
            } else {
              $route.reload()
            }
          } else {
            if (typeof res.IPResult.info !== 'undefined')
              alert(res.IPResult.info.statusCode + ' ' + res.IPResult.info.status)
            else if (typeof res.IPResult.error !== 'undefined')
              alert(res.IPResult.error.Errors + '')
            else if (res.IPResult.result != null && res.IPResult.result.errors != null) {
              var errorMessages = [];
              for (let i in res.IPResult.result.errors) {
                for (let j in res.IPResult.result.errors[i]) {
                  for (let k in res.IPResult.result.errors[i][j]) {
                    errorMessages.push(res.IPResult.result.errors[i][j][k]);
                  }
                }
              }
              if (errorMessages.length > 0) {
                alert('An exception occurred: '+ errorMessages.join('. '));
              }
            }
          }
        }

      } else {
        // should never see this
        alert('Invalid response from RefreshDSATClass.getRefreshAPIDetails')
      }
    })
  }

  $scope.toggleSelection = function toggleSelection(item) {
    const selectedAccount = selectedLocations.filter(acc => {
      return acc.Id == item.Id
    });
    if (selectedAccount[0]) {
      selectedLocations = selectedLocations.filter(acc => {
        return acc.Id != item.Id
      });
    } else {
      selectedLocations.push(item)
    }
    // // is currently selected
    // if (idx > -1) {
    //   selectedLocations.splice(idx, 1)
    //   item.locationChecked = false
    // } else {
    //   // if is newly selected, add it to checked locations
    //   selectedLocations.push(item)
    //   item.locationChecked = true
    // }


    console.log('checked items include', selectedLocations)
    checkDSAT();

    if (selectedLocations.length>0){
      console.log('inside if');
       document.getElementById('customNextBtn').disabled = false;
    }
    else{
      console.log('inside else');
      document.getElementById('customNextBtn').disabled = true;
    }
    // save checked items into OmniScript JSON
    $scope.bpTree.response.SelectedLocations = selectedLocations


  }

  baseCtrl.prototype.triggerNextStep = function(control,scp) {
    if (control === undefined || control === null ) {
        return;
    }

    console.log(selectedLocations) 
    scp.nextRepeater(control.rootIndex + 1, control.rootIndex);

};
}])