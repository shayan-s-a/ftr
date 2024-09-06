vlocity.cardframework.registerModule.controller('customerInfoController', ['$scope', '$window', '$timeout', '$filter', '$rootScope', '$document', 'bpService', '$q', function ($scope, $window, $timeout, $filter, $rootScope, $document, bpService, $q) {

  $scope.bpTree.response.IsCheckboxChecked = true
  $scope.buttonClicked = "Not yet!"
  
  if ($scope.bpTree.response.locationOpenId) {
    $("#SILocationInfoBlock").css('display', 'block');
  } else {
    $("#SILocationInfoBlock").css('display', 'none');
  }
    let errorFields = [];

  // define arrays for use in this template
  $scope.locationsTableArray = []
  var selectedLocations = $scope.bpTree.response.SelectedLocations || [] // Values from Quote selectedLocations field

  function checkDSAT() {
    $scope.bpTree.response.IsCheckboxChecked = true
    if (Array.isArray(selectedLocations)) {
      var d = new Date()
      for (let i = 0; i < selectedLocations.length; i++) {
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

  $scope.showLocationInfo = function (record) {
    $("#errorMessage").html('');
    console.log($("#errorMessage"));
    console.log(record);
    debugger
    $("#SILocationInfoBlock > div > label > .nds-form-element__label_toggleText").html('Location: ' + record.Address);
    $scope.bpTree.shippingInfoId = record.Id;
    
    if ($scope.bpTree.response.locationOpenId == record.Id) {
      $scope.bpTree.response.locationOpenId = '';
      $("#SILocationInfoBlock").css('display', 'none');
    } else {
        var input = {
          DRParams: { ShippingInfoId: $scope.bpTree.shippingInfoId },
          Bundle: 'Get_ShippingDevicesBYShipInfo'
        };

        var configObj = {
          sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
          sMethodName: 'invokeOutboundDR',
          input: angular.toJson(input),
          options: angular.toJson({ "useQueueableApexRemoting": false })
        };
        executeRemoteAction(configObj, record);
    }
  };
  // function to delete the location from the shipping information table
  $scope.toggleDeleteMode = function (record) {
    let errorFields = [];
    var configObj = {
      sClassName: '%vlocity_namespace%.IntegrationProcedureService',
      sMethodName: 'RingCentral_DeleteShippingAddress',
      input: angular.toJson({ AddressToDelete: record.Id, OrderId: $scope.bpTree.response.OrderId }),
      options: angular.toJson({})
    };
    executeRemoteAction(configObj);
    $scope.addErrorMsg = null;
    $scope.bpTree.response.locationOpenId = '';
     $("#SILocationInfoBlock").css('display', 'none');

  }
   // Added to check if there is no location added in the step , stop the process
   

  function executeRemoteAction(configObj, record) {
    $rootScope.loading = true;
    return $q(function (resolve, reject) {
      bpService.OmniRemoteInvoke(configObj).then(function (result) {
        var remoteResp = angular.fromJson(result);
        console.log(configObj.sMethodName + ' result:', remoteResp);
        if (remoteResp && remoteResp.IPResult && remoteResp.error == 'OK') {
          remoteResp = remoteResp.IPResult;

          $scope.shippingaddresses = remoteResp;
          if (remoteResp.success == false) {
            if (remoteResp.result[0].errors)
              alert(JSON.stringify(remoteResp.result[0].errors));
            $rootScope.loading = false;
            reject(remoteResp);
          }
          setElementValue('ShippingInformationDetails', remoteResp.ShippingInformationDetails);
          $rootScope.loading = false;
        } else if (remoteResp && remoteResp.OBDRresp && remoteResp.error == 'OK') {
          remoteResp = remoteResp.OBDRresp;
          if (configObj.sMethodName == 'invokeOutboundDR') {
            $scope.bpTree.response.ShippingDeviceDetails = remoteResp.ShippingDevices;
            $scope.bpTree.response.locationOpenId = record.Id;
            $("#SILocationInfoBlock").css('display', 'block');
          }
          $rootScope.loading = false;
        } else {
          console.error('Error in calling DR ', remoteResp);
          if (remoteResp.error)
            alert(remoteResp.error);
          $rootScope.loading = false;
          reject(remoteResp);
        }
        resolve(remoteResp)
      }).catch(function (error) {
        console.error('Error while calling DR ', error);
        alert(JSON.stringify(error));
        $rootScope.loading = false;
        reject(error);
      });
    });
  }

  // function getShippingInfoDetails() {
  //         debugger
  //         var input = {
  //             DRParams: { OrderId:$scope.bpTree.response.OrderId},
  //             Bundle:  'GetShippingInfoDetails'
  //         };
  //         var configObj = {
  //             sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
  //             sMethodName: 'invokeOutboundDR',
  //             input: angular.toJson(input),
  //             options:angular.toJson({ "useQueueableApexRemoting": false })
  //         };
  //         executeRemoteAction(configObj);
  //     }
  function setElementValue(name, value) {
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
  function getElementValue(name, cursor) {
    let namePath = name.split(/[:\.]/);
    let p;
    if (!cursor)
      cursor = $scope.bpTree.response;
    while (undefined !== (p = namePath.shift())) {
      if (p.startsWith('#')) {
        p = p.substr(1);
        let kv = p.split('=');
        let newCursor = undefined;
        for (let i = 0; i < cursor.length; i++) {
          if (cursor[i][kv[0]] == kv[1]) {
            newCursor = cursor[i];
            break;
          }
        }
        cursor = newCursor;
      } else {
        cursor = cursor[p];
      }
      if (cursor === undefined) {
        break;
      }
    }
    return cursor;
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
    }

  }

  $scope.init = function () {
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
                alert('An exception occurred: ' + errorMessages.join('. '));
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
    // save checked items into OmniScript JSON
    $scope.bpTree.response.SelectedLocations = selectedLocations
  }
}])