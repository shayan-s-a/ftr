vlocity.cardframework.registerModule.controller('UCFHotCutLocationSelectablesController', ['$scope', '$rootScope', '$q', 'bpService', '$timeout', function ($scope, $rootScope, $q, bpService, $timeout) {
    $scope.duedateLocations = [];
    $scope.init = function () {
        var input = {
            DRParams: { OrderId: $scope.bpTree.response.ContextId },
            Bundle: 'DR_GetDueDateByLocId'
        };
        var configObj = {
            sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
            sMethodName: 'invokeOutboundDR',
            input: angular.toJson(input),
            options: angular.toJson({ "useQueueableApexRemoting": false })
        };
        $scope.duedateLocations = [];
        executeRemoteAction(configObj).then(sleep(2000)).then(resp => {
            console.log(resp.Locations);
            angular.forEach(resp.Locations, function (item) {
                $scope.duedateLocations[item.Id] = item.DueDate;
            });
            /* if ($scope.bpTree.response[$scope.child.eleArray[0].propSetMap.path].includes(item.Id)) {
                item.selected = true;
            } */
            console.log($scope.duedateLocations);
            // setElementValue('DueDateLocations', $scope.duedateLocations);
        }).catch(err => {
            console.log(err);
        });
    }

    $scope.init();

    const date = new Date();
    let day = date.getDate();
    let month = date.getMonth() + 1;
    let year = date.getFullYear();
    $scope.minDate = new Date().toISOString().split('T')[0];
    console.log($scope.minDate);
    $scope.dueDates = {};

    $scope.disabled = function (date, mode) {
        return (mode === 'day' && (date.getDay() === 0));
    };
    const currentDate = new Date();
    const newday = new Date();
    newday.setDate(currentDate.getDate() + 1);
    var tomorrow = newday.toISOString().split('T')[0];
    $scope.bpTree.response.mindate = tomorrow;
    // pagination
    $scope.table = {
        isAllSelected: false,
        currentPage: 0,
        q: '',
        data: [],
        fullData: [],
        page: 1,
        startingRecord: 1,
        endingRecord: 0,
        pageSize: '10',
        offSet: 0,
        offSetStart: 0,
        offSetEnd: 10,
        totalRecordCount: 0,
        totalPage: 0
    };

    $scope.alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    $scope.range = function (min, max, step) {
        step = step || 1;
        var input = [];
        for (var i = min; i <= max; i += step) {
            input.push(i);
        }
        return input;
    };
    $scope.setDueDate = function (recordId, index) {
        let value = document.getElementById("datepicker_" + recordId).value;
        let dateToday = new Date().toISOString().split('T')[0];
        if (value < dateToday) {
            document.getElementById("datepicker_" + recordId).value = '';
            alert('Invalid date selected');
            return false;
        }
        $scope.bpTree.response.Locations[index].DueDate = value;
        $scope.bpTree.response.Locations[index].SetDueDate = true;
        console.log($scope.bpTree.response.Locations[index]);
    }

    $scope.$watch('bpTree.response.' + $scope.child.eleArray[0].propSetMap.data, function (newVal, oldVal) {
        console.log(newVal);
        console.log(oldVal);
        if (newVal) {
            if (Array.isArray(newVal)) {
                $scope.table.fullData = newVal;
                $scope.table.totalRecordCount = newVal.length;
            } else {
                $scope.tableData = [newVal];
            }
            if (newVal.length <= 10) {
                $scope.table.pageSize = newVal.length;
            }
            $scope.tableData = [];
            for (var i = $scope.table.offSet; i <= parseInt($scope.table.pageSize); i++) {
                $scope.tableData.push(newVal[i]);
            }
            //const uniqueItems = removeDuplicatesByKey($scope.tableData, 'Id');
            //$scope.tableData = [];
            //$scope.tableData = uniqueItems;
            //console.log(uniqueItems);
            console.log($scope.tableData);
        } else {
            $scope.tableData = [];
        }
    });

    $scope.numberOfPages = function () {
        return Math.ceil($scope.table.totalRecordCount / $scope.table.pageSize);
    }

    $scope.previousHandler = function () {
        $scope.tableData = [];
        $scope.table.currentPage = $scope.table.currentPage - 1;
        $scope.table.offSet = $scope.table.offSet - parseInt($scope.table.pageSize);
        var nextpage = $scope.table.currentPage + 1
        var offsetStart = $scope.table.currentPage * $scope.table.pageSize;
        var offsetEnd = $scope.table.pageSize * nextpage;
        console.log(offsetStart + 1);
        console.log(offsetEnd);

        for (var i = offsetStart; i <= parseInt(offsetEnd); i++) {
            if ($scope.table.fullData[i]) {
                $scope.tableData.push($scope.table.fullData[i]);
            }
        }
    }

    $scope.nextHandler = function () {
        $scope.tableData = [];
        $scope.table.currentPage = $scope.table.currentPage + 1;
        $scope.table.offSet = $scope.table.offSet + parseInt($scope.table.pageSize);
        var nextpage = $scope.table.currentPage + 1
        var offsetStart = $scope.table.currentPage * $scope.table.pageSize;
        var offsetEnd = $scope.table.pageSize * nextpage;
        console.log(offsetStart + 1);
        console.log(offsetEnd);
        for (var i = offsetStart; i <= parseInt(offsetEnd); i++) {
            if ($scope.table.fullData[i]) {
                $scope.tableData.push($scope.table.fullData[i]);
            }
            //console.log(newVal[i]);
        }
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


    /**
     * @desc: will update the value selected to whatever path is set in the propSetMap
     * this is only enabled if you set selectable = true in the propSetMap
     */
    $scope.evaluateChange = function (record) {
        console.log($scope.child.eleArray[0].propSetMap.path, record);

        // add to list if multi select, else just set the value
        if ($scope.child.eleArray[0].propSetMap.multiSelect) {
            let lst = getElementValue($scope.child.eleArray[0].propSetMap.path);
            if (lst) {
                lst = lst.split(';');
                // if its in the list, remove it, else add it
                let index = lst.indexOf(record.Id);
                if (index != -1) {
                    lst.splice(index, 1);
                } else {
                    lst.push(record.Id);
                }
            } else {
                lst = [record.Id];
            }
            setElementValue($scope.child.eleArray[0].propSetMap.path, null);
            setElementValue($scope.child.eleArray[0].propSetMap.path, lst.join(';'));
        } else {
            setElementValue($scope.child.eleArray[0].propSetMap.path, null);
            setElementValue($scope.child.eleArray[0].propSetMap.path, record);
        }
    }

    // makes sure the correct items are selected in the table
    if ($scope.child.eleArray[0].propSetMap.multiSelect) {
        $scope.$watch('bpTree.response.' + $scope.child.eleArray[0].propSetMap.data, function (newVal, oldVal) {
            if (newVal) {
                angular.forEach($scope.bpTree.response[$scope.child.eleArray[0].propSetMap.data], function (item) {
                    if ($scope.bpTree.response[$scope.child.eleArray[0].propSetMap.path].includes(item.Id)) {
                        item.selected = true;
                    }
                });
            }
        });
    }

    function removeDuplicatesByKey(arr, key) {
        var unique = {};
        var uniqueArray = [];

        angular.forEach(arr, function (item) {
            if (item && item.Id && !unique[item.Id]) {
                unique[item.Id] = true;
                console.log(item);
                uniqueArray.push(item);
            }
        });

        return uniqueArray;
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

    function executeRemoteAction(configObj, record) {
        $rootScope.loading = true;
        return $q(function (resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(function (result) {
                var remoteResp = angular.fromJson(result);
                console.log(configObj.sMethodName + ' result:', remoteResp);
                if (remoteResp && remoteResp.IPResult && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.IPResult;
                    if (remoteResp.success == false) {
                        if (remoteResp.result[0].errors) {
                            alert(JSON.stringify(remoteResp.result[0].errors));
                            $rootScope.loading = false;
                            reject(remoteResp);
                        }
                    }
                    setElementValue('ShippingInformationDetails', remoteResp.ShippingInformationDetails);
                    $rootScope.loading = false;
                } else if (remoteResp && remoteResp.OBDRresp && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.OBDRresp;
                    if (configObj.sMethodName == 'invokeOutboundDR') {
                        $scope.shippingDevicesDetails = remoteResp.ShippingDevices
                        $scope.shippingInfoDetails = remoteResp.ShippingInformationDetails
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

}]);
function sleep(delay) {
    var start = new Date().getTime();
    while (new Date().getTime() < start + delay);
}