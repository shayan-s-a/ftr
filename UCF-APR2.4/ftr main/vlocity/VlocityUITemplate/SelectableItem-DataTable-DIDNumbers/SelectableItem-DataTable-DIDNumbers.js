vlocity.cardframework.registerModule.controller('customTableControllerDID', ['$scope','$window', '$timeout','$filter', '$rootScope','$document','bpService','$q', function($scope, $window,$timeout, $filter, $rootScope, $document,bpService,$q) {
    
    $scope.sort = {
        column: '',
        descending: false
    };

    $scope.bpPaths = {
        didLocationId: 'DIDLocationDetails.DIDLocationId'
    };

    if ($scope.child.eleArray[0].propSetMap.isUCF) {
        $scope.bpPaths.didLocationId = 'MainDIDLocationId';
    }

    $scope.dataInsertChunkSize = 500;

    $scope.table = {
        isAllSelected: false,
        currentPage: 0,
        q: '',
        data: [],
        fullData: [],
        page: 1,
        startingRecord: 1,
        endingRecord: 0,
        pageSize: '100',
        offSet: 0,
        totalRecordCount: 0,
        totalPage: 0
    };
    
    $scope.table.columns = [];
    angular.forEach($scope.child.eleArray[0].propSetMap.columns, (col) => {
        if ($scope.child.eleArray[0].propSetMap.osName == 'UCF Enrichment') {
            $scope.table.columns.push(col.label);
        } else {
            $scope.table.columns.push(col.apiName);
        }
    });
    $scope.table.columns = 'Required column headers: \r\n' + $scope.table.columns.join('\r\n');


    $scope.$watch('bpTree.response.DIDNumbers', (newVal, oldVal) => {
        if (newVal != oldVal) {
            // set the table data
            $scope.table.data = newVal;
            $scope.table.totalRecordCount = $scope.bpTree.response.totalDIDNumberRecordCount;
        }
    });

    $scope.$watch('q', function(newValue,oldValue){
        if(oldValue!=newValue){
            // reset to the first page when the search text changes
            $scope.table.currentPage = 0;
        }
    },true);

    // filter data with search text
    $scope.getData = function () {
        $scope.table.offSet = 0;
        getNumberDetails();
    }

    $scope.numberOfPages=function(){
        return Math.ceil($scope.table.totalRecordCount/$scope.table.pageSize);
    }

    $scope.sortColumn = function(column) {
  
        var sort = $scope.sort;
  
        if (sort.column == column) {
            sort.descending = !sort.descending;
        } else {
            sort.column = column;
            sort.descending = false;
        }
    };

    $scope.previousHandler = function() {
        $scope.table.currentPage = $scope.table.currentPage - 1;
        $scope.table.offSet = $scope.table.offSet - parseInt($scope.table.pageSize);
        getNumberDetails();
    }

    $scope.nextHandler = function() {
        $scope.table.currentPage = $scope.table.currentPage + 1;  
        $scope.table.offSet = $scope.table.offSet + parseInt($scope.table.pageSize);
        getNumberDetails();
    }
    
    function getNumberDetails() {
        var input = {
            DRParams: { DIDLocationId: getElementValue($scope.bpPaths.didLocationId), pageOffset: $scope.table.offSet },
            Bundle:  'GetDIDNumberDetails'
        };
        if ($scope.table.q != '' && $scope.table.q != null) {
            input.DRParams.searchKey = $scope.table.q + '%';
            input.Bundle = 'SearchDIDNumberDetails';
        }
        
        var configObj = {
            sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
            sMethodName: 'invokeOutboundDR',
            input: angular.toJson(input),
            options:angular.toJson({ "useQueueableApexRemoting": false })
        };
        executeRemoteAction(configObj);
    }

    $scope.toggleAll = function() {
        angular.forEach($scope.table.data, function(itm){ 
            itm.selected = $scope.table.isAllSelected; 
        });
    }

    $scope.table.isAnySelected = function() {
        var trues = $filter("filter")($scope.table.data, {
            selected: true
        });
        return trues.length;
    };

    $scope.optionToggled = function(){
        $scope.table.isAllSelected = $scope.table.data.every(function(itm){ return itm.selected; });
    }

    $scope.downloadTemplate = function() {
        let url = $scope.bpTree.response.sfdcIFrameOrigin.replaceAll('vlocity-cmt', 'c');
        $window.open(url + '/resource/'+ $scope.bpTree.response.didNumberTemplate +'?');
    }


    $scope.openDIDNumberView = function(test) {
        let url = $scope.bpTree.response.sfdcIFrameOrigin.replaceAll('vlocity-cmt', 'c');
        let vfPage = $scope.child.eleArray[0].propSetMap.osName == 'UCF Enrichment' ? 'UCFNumberView' : 'DIDNumberView';
        if (test)
            $window.open(url + '/apex/' + vfPage + '?didLocationId=' + $scope.bpTree.response.DIDLocationDetails.DIDLocationId, '_blank');
        else
            $window.open(url + '/lightning/r/'+ $scope.bpTree.response.DIDLocationDetails.DIDLocationId +'/related/DID_Number_Details__r/view', '_blank');
    }

    $scope.toggleEditMode = function(record) {
        let errorFields = [];
        
        if (record.editMode) {
            // check all required fields
            angular.forEach($scope.child.eleArray[0].propSetMap.columns, (col) => {
                if (col.required && !record[col.apiName]) {
                    errorFields.push(col.label);
                }
            });
            
            // if no missing fields, make callout to update the numbers
            if (errorFields.length > 0) {
                if (errorFields.length == 1)
                    $scope.addErrorMsg = 'Required field is missing: '; 
                else
                    $scope.addErrorMsg = 'Required fields are missing: ';
                $scope.addErrorMsg += errorFields.join(', ');
                return;
            } else {

                var configObj = {
                    sClassName: '%vlocity_namespace%.IntegrationProcedureService',
                    sMethodName: 'DID_UpdateNumbers',
                    input: angular.toJson({ DIDNumber: record }),
                    options:angular.toJson({})
                };
                executeRemoteAction(configObj, record);
            }
        } else {
            record.editMode = !record.editMode;
            $scope.addErrorMsg = null;
        }
        
    }

    $scope.showNewRecord = true;

    // $scope.toggleShowNewRecord = function() {
    //     $scope.showNewRecord = !$scope.showNewRecord;
    // }

    $scope.addRecord = function(record) {
        let errorFields = [];
        angular.forEach($scope.child.eleArray[0].propSetMap.columns, (col) => {
            if (col.required && !record[col.apiName]) {
                errorFields.push(col.label);
            }
        });
        if (errorFields.length > 0) {
            $scope.addErrorMsg = errorFields.length == 1 ? 'Required field is missing: ' : 'Required fields are missing: ';
            $scope.addErrorMsg += errorFields.join(', ');
            return;
        } else {
            var result = [{records: [record] }];
            var configObj = {
                sClassName: '%vlocity_namespace%.IntegrationProcedureService',
                sMethodName: 'DID_InsertNewNumbers',
                input: angular.toJson({NewDIDNumbers: result, DIDLocationId: getElementValue($scope.bpPaths.didLocationId)}),
                options:angular.toJson({
                    "chainable": true,
                    "useContinuation": true,
                    "vlcClass": "%vlocity_namespace%.IntegrationProcedureService"
                })
            };
            executeRemoteAction(configObj);
            $scope.table.currentPage = 0;
            record.editMode = !record.editMode;
            // if (!$scope.table.fullData) {
            //     $scope.table.fullData = [record];
            // } else {
            //     $scope.table.fullData.unshift(record);
            // }
            // setElementValue('DIDNumbers', $scope.table.fullData);
            $scope.resetNewRecord();
            // $scope.toggleShowNewRecord();
            
        }
    }

    function executeRemoteAction(configObj, record) {
        $rootScope.loading = true;
        return $q(function(resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(function(result) {
                var remoteResp = angular.fromJson(result);
                if(remoteResp && remoteResp.IPResult && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.IPResult;

                    // if the VIP is still in pregress... call again
                    if (remoteResp.hasOwnProperty('vlcIPData')
                        && remoteResp.hasOwnProperty('vlcStatus')
                        && remoteResp.vlcStatus === 'InProgress') {

                        $rootScope.loading = true;
                        // overwriting as object in order to use same prop, but also have different display conditions
                        $rootScope.loadingMessage = {actionMessage: remoteResp.vlcMessage};

                        configObj.options = angular.toJson(remoteResp);
                        configObj.input = '{}';

                        return executeRemoteAction(configObj);
                    } else {
                        if (remoteResp.success == false) {
                            if (remoteResp.result[0].errors)
                                alert(JSON.stringify(remoteResp.result[0].errors));
                            $rootScope.loading = false;
                            reject(remoteResp);
                        }
                        // check who's calling this
                        if (configObj.sMethodName == 'DID_UpdateNumbers') {
                            if (record) {
                                record.editMode = !record.editMode;
                                $scope.addErrorMsg = null;
                            }
                        } else {
                            setElementValue('DIDNumbers', remoteResp.DIDNumbers);
                            setElementValue('totalDIDNumberRecordCount', remoteResp.totalDIDNumberRecordCount);
                        }
                        $rootScope.loading = false;
                    }
                } else if (remoteResp && remoteResp.OBDRresp && remoteResp.error == 'OK')  {
                    remoteResp = remoteResp.OBDRresp;
                    $scope.bpTree.response.DIDNumbers = remoteResp.DIDNumbers;
                    // setElementValue('DIDNumbers', remoteResp.DIDNumbers);
                    setElementValue('totalDIDNumberRecordCount', remoteResp.totalDIDNumberRecordCount);
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

    $scope.resetNewRecord = function() {
        $scope.newRecord = {
            editMode: true
        };
        angular.forEach($scope.child.eleArray[0].propSetMap.columns, (col) => {
            $scope.newRecord[col.apiName] = col.default;
        });
        $scope.addErrorMsg = null;
    }

    $scope.refreshTable = function() {
        getNumberDetails();
    }

    $scope.newRecord = { editMode: true };

/**
 * @desc: removes the items from the display.  if the item has an  Id, need to do a database call
 */
    $scope.deleteSelectedRecords = function() {
        $scope.itemsToDelete = [];
        angular.forEach($scope.table.data, function(item){
            if (item.selected) {
                $scope.itemsToDelete.push(item.Id);
            }
        });
        var configObj = {
            sClassName: '%vlocity_namespace%.IntegrationProcedureService',
            sMethodName: 'DID_DeleteNumbers',
            input: angular.toJson({ NumbersToDelete: $scope.itemsToDelete, DIDLocationId: getElementValue($scope.bpPaths.didLocationId) }),
            options:angular.toJson({})
        };
        executeRemoteAction(configObj);
    }


// /**
//  * @desc: will update the value selected to whatever path is set in the propSetMap
//  * this is only enabled if you set selectable = true in the propSetMap
//  */
//     $scope.toggleSelection = function(data) {
//         if ($scope.selectedRecords.indexOf(data) != -1) {
//             $scope.selectedRecords.splice($scope.selectedRecords.indexOf('B'), 1);
//         } else {
//             $scope.selectedRecords.push(data);
//         }
//         console.log('selected records: ',$scope.selectedRecords);
//         // setElementValue($scope.child.eleArray[0].propSetMap.path, null);
//         // setElementValue($scope.child.eleArray[0].propSetMap.path, obj);
//     }
    
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

    function getElementValue (name, cursor) {
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

    $scope.uploadResult = {};

    /**
     * Returns an array with arrays of the given size.
     *
     * @param myArray {Array} Array to split
     * @param chunkSize {Integer} Size of every group
     */
    function chunkArray(myArray, chunk_size){
        var results = [];
        
        while (myArray.length) {
            results.push(myArray.splice(0, chunk_size));
        }
        
        return results;
    }

    $scope.$watch('fileContent', (newVal, oldVal) => {
        if (newVal) {
            const columns = $scope.child.eleArray[0].propSetMap.columns;
            try {
                var data = newVal.split('\r\n');
                // remove last item in array
                var headers = data[0].split(',');
                // ensure csv columns match with table columns
                if (headers.length == columns.length) {
                    for (let i=0; i < columns.length; i++) {
                        var apiName = $scope.child.eleArray[0].propSetMap.osName == 'UCF Enrichment' ? columns[i].label : columns[i].apiName;
                        if (headers.indexOf(apiName) == -1) {
                            $scope.uploadResult.error = true;
                            $scope.uploadResult.msg = 'Unable to process file';
                            $timeout(function(){ 
                                $scope.uploadResult.msg = null;
                            }, 5000);
                            return;
                        }
                    }
                } else {
                    $scope.uploadResult.error = true;
                    $scope.uploadResult.msg = 'Unable to process file';
                    $timeout(function(){ 
                        $scope.uploadResult.msg = null;
                    }, 5000);
                    return;
                }
                if (data[1]) {
                    var dataSet = [];
                    for (let i=1; i< data.length; i++) {
                        if (data[i]) {
                            let row = data[i].split(',');
                            let obj = {};
                            for (let j=0; j<row.length; j++) {
                                obj[columns[j].apiName] = row[j];
                            }
                            dataSet.push(obj);
                        }
                    }
                    var opt = {
                        "chainable": true,
                        "useContinuation": true,
                        "vlcClass": "%vlocity_namespace%.IntegrationProcedureService"
                    };
                    var result = [];
                    // if (dataSet.length > 1000) opt.useFuture = true;
                    angular.forEach(chunkArray(dataSet, $scope.dataInsertChunkSize), (records) => {
                        result.push({records: records });
                    });

                    var sMethodName = $scope.child.eleArray[0].propSetMap.osName == 'UCF Enrichment' ? 'UCF_InsertNewNumbers' : 'DID_InsertNewNumbers';

                    var configObj = {
                        sClassName: '%vlocity_namespace%.IntegrationProcedureService',
                        sMethodName: 'DID_InsertNewNumbers',
                        input: angular.toJson({NewDIDNumbers: result, DIDLocationId: getElementValue($scope.bpPaths.didLocationId)}),
                        options:angular.toJson(opt)
                    };
                    executeRemoteAction(configObj, null);
                }
            } catch (error) {
                console.error(error);
                $scope.uploadResult.error = true;
                $scope.uploadResult.msg = 'Unable to process file';
                $timeout(function(){ 
                    $scope.uploadResult.msg = null;
                }, 5000);
                return;
            }
            $scope.fileContent = null;
            angular.element("#csvUpload").val(null);
        }
    });

    // $scope.clear = function () {
    //     
    // };

}]);
vlocity.cardframework.registerModule.directive('fileReader', function() {
  return {
    scope: {
      fileReader:"="
    },
    link: function(scope, element) {
      $(element).on('change', function(changeEvent) {
        var files = changeEvent.target.files;
        if (files.length) {
          var r = new FileReader();
          r.onload = function(e) {
              var contents = e.target.result;
              scope.$apply(function () {
                scope.fileReader = contents;
                scope.testing = contents;
              });
          };
          r.readAsText(files[0]);
        }
      });
    }
  };
});
vlocity.cardframework.registerModule.filter('startFrom', function() {
    return function(input, start) {
        start = +start;
        return input.slice(start);
    }
});
vlocity.cardframework.registerModule.filter('tel', function () {
    return function (tel) {
        if (!tel) { return ''; }

        var value = tel.toString().trim().replace(/^\+/, '');

        if (value.match(/[^0-9]/)) {
            return tel;
        }

        var country, city, number;

        switch (value.length) {
            case 10: // +1PPP####### -> C (PPP) ###-####
                country = 1;
                city = value.slice(0, 3);
                number = value.slice(3);
                break;

            case 11: // +CPPP####### -> CCC (PP) ###-####
                country = value[0];
                city = value.slice(1, 4);
                number = value.slice(4);
                break;

            case 12: // +CCCPP####### -> CCC (PP) ###-####
                country = value.slice(0, 3);
                city = value.slice(3, 5);
                number = value.slice(5);
                break;

            default:
                return tel;
        }

        if (country == 1) {
            country = "";
        }

        number = number.slice(0, 3) + '-' + number.slice(3);

        return (country + " (" + city + ") " + number).trim();
    };
});