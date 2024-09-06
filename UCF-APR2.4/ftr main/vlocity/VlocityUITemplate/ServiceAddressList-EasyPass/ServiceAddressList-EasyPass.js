vlocity.cardframework.registerModule.controller('customerInfoController', ['$scope', function($scope) {

    $scope.bpTree.response.IsCheckboxChecked = true
    $scope.tiersList = ['Tier 2','3','BDT'];
  
    // define arrays for use in this template
    $scope.locationsTableArray = []
    var selectedLocations = $scope.bpTree.response.selectedLocations || [] // Values from Quote selectedLocations field
  
    // function to merge selected Locations with service Accounts
    var mergeLocations = function() {
        var serviceAccounts = $scope.bpTree.response.ServiceAccounts || [] // Values from DR Extract of Service Accounts
        var finalData = []
        var checkflag = false
        // if selectedLocations has values, merge those with the full list of Service Accounts and show them as checked
        if (selectedLocations != null || selectedLocations !== undefined || selectedLocations !== '') {
            angular.forEach(serviceAccounts, function(serviceAcctData) {
                angular.forEach(selectedLocations, function(selectedLocData) {
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
            $scope.bpTree.response.ServiceAccountsUpdated = false
        } else {
            $scope.locationsTableArray = $scope.bpTree.response.ServiceAccounts || []
            $scope.bpTree.response.ServiceAccountsUpdated = false
  
        }
  
    }
  
    $scope.init = function() {
        mergeLocations()
    }
  
    $scope.$watch('bpTree.response.ServiceAccountsUpdated', function() {
        if ($scope.bpTree.response.ServiceAccountsUpdated) {
            $scope.bpTree.response.selectedLocations.length = 0;
            mergeLocations()
        }
    })
  
    $scope.$watch('bpTree.response.ServiceAccounts', function() {
      if ($scope.bpTree.response.ServiceAccounts) {
          mergeLocations()
      }
  })
  
      $scope.toggleTypeAheadBlock = function() {
        $scope.bpTree.response.showTypeAhead = !$scope.bpTree.response.showTypeAhead;
    }
  
    $scope.showTypeAheadBlock = function() {
        $scope.bpTree.response.showTypeAhead = true
    }
    $scope.hideTypeAheadBlock = function() {
        $scope.bpTree.response.showTypeAhead = false
    }
  
    $scope.sort = {
        column: '',
        descending: false
    };
  
    $scope.sortColumn = function(column) {
  
        var sort = $scope.sort;
  
        if (sort.column == column) {
            sort.descending = !sort.descending;
        } else {
            sort.column = column;
            sort.descending = false;
        }
    };
  
    $scope.selectedCls = function(column) {
        return column == $scope.sort.column && 'sort-' + $scope.sort.descending;
    };
  
  
    $scope.onSelectItem = function(acct, selectedRecord) {
        var d = new Date()
        var getDate = acct.Premises.Last_DSAT_Check__c
        acct.name = acct.ShippingStreet + ' ' + acct.ShippingCity + ', ' + acct.ShippingState + ' ' + acct.ShippingPostalCode;
        acct.value = acct.Id;
        var now = new Date(getDate)
        now.setDate(now.getDate() + 30) // This should be a 30 day check, not 14 - Sean
  
        if (selectedRecord) {
            if (now < d) {
                $scope.bpTree.response.IsCheckboxChecked = false
            }
        } else {
            if (now >= d) {
  
            } else {
                $scope.bpTree.response.IsCheckboxChecked = true
            }
        }
    }
  
    $scope.iconclick = function(record) {
        $scope.isLoading = true
        // Keeping Backup of this data which made by sean
        var ipInput = {
            AQRecordId: 0,
            OpportunityId: '',
            Address: record.ShippingStreet,
            City: record.ShippingCity,
            State: record.ShippingState,
            ZipCode: record.ShippingPostalCode,
            BusinessName: record.Name,
            ParentAccountId: $scope.bpTree.response.ParentAccountId,
            ContextId: $scope.bpTree.response.ContextId,
            PremisesId: record.Premises ? record.Premises.Id : null
        }
  
        var option = {}
        $scope.bpService.GenericInvoke('RefreshDSATClass', 'getRefreshAPIDetails', angular.toJson(ipInput), angular.toJson(option)).then(function(result) {
            $scope.isLoading = false
            console.log('After the Apex call', result)
  
            if (typeof result !== 'undefined') {
                var res = JSON.parse(result)
                console.log('Result of refresh:', res);
                if (res && res.IPResult) {
                  if (res.IPResult.success || res.IPResult.ServiceAccountsUpdated) {
                    window.location.reload()
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
        .catch(error => { 
          alert(`The unknown error has occurred: ${error}`);
        });
    }
  
    $scope.toggleSelection = function toggleSelection(item) {
        const idx = selectedLocations.indexOf(item)
        // is currently selected
        if (idx > -1) {
            selectedLocations.splice(idx, 1)
            item.locationChecked = false
        } else {
            // if is newly selected, add it to checked locations
            selectedLocations.push(item)
            item.locationChecked = true
        }
        console.log('checked items include', selectedLocations)
        // save checked items into OmniScript JSON
        $scope.bpTree.response.selectedLocations = selectedLocations
    }
  }])