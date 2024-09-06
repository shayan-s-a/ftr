vlocity.cardframework.registerModule.controller('vltNdsStepController', ['$scope', '$rootScope', '$q', 'bpService', '$timeout', function ($scope, $rootScope, $q, bpService, $timeout) {
    $scope.shippingDevicesDetails = '';
    $scope.shippingInfoDetails = '';

    $scope.init = function () {
        if ($scope.child.name == 'ShippingInformation') {
            var input = {
                DRParams: { OrderId: $scope.bpTree.response.ContextId },
                Bundle: 'DR_GetShippingInfoByOrderIdV5'
            };
            var configObj = {
                sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
                sMethodName: 'invokeOutboundDR',
                input: angular.toJson(input),
                options: angular.toJson({ "useQueueableApexRemoting": false })
            };
            executeRemoteAction(configObj);
        }
    }

    $scope.navigateToCart = function () {
        window.location.href = '/apex/%vlocity_namespace%__hybridcpq?id=' + $scope.bpTree.response.ContextId;
    }

    $scope.hideModal = function () {
        $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
        $scope.modal.showModal = true;
    }

    $scope.goNext = function (step) {
        console.log(step);
        if (stepIsValid(step)) {
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
        }
    }

    function gotoStep(stepName) {
        for (let i = 0; i < $scope.bpTree.children.length; i++) {
            if ($scope.bpTree.children[i].name == stepName) {
                $scope.sidebarNav($scope.bpTree.children[i]);
                return;
            }
        }
    }

    function stepIsValid(step) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };

        if (step.name == 'DisplayServiceLocations') {
            if (!$scope.bpTree.response.hasOwnProperty('SelectedLocations') || $scope.bpTree.response.SelectedLocations.length == 0) {
                $scope.modal.msgs.push('Service location is required.');
            } else if ($scope.bpTree.response.SelectedLocations.length > 0) {
                for (let i = 0; i < $scope.bpTree.response.SelectedLocations.length; i++) {
                    let location = $scope.bpTree.response.SelectedLocations[i];
                    if (location.Premises == null) {
                        $scope.modal.msgs.push(location.ShippingStreet + ' requires a DSAT refresh.');
                    }
                }
            }


        } else if (step.name == 'QuoteCreation') {
            $scope.modal.msgs = getFieldErrors(step);
        }
        else if (step.name == 'ShippingInformation') {
            let errorFields = [];
            let allocatedDevices = 0;
            let totalDevices = 0;
            if ($scope.shippingDevicesDetails.length > 1) {
                $scope.shippingDevicesDetails.forEach(obj => {
                    totalDevices += obj.Total;
                });
            } else {
                totalDevices += $scope.shippingDevicesDetails.Total;
            }
            let locationShippingInfo = '';
            if ($scope.bpTree.response.ShippingInformationDetails != null) {
                locationShippingInfo = $scope.bpTree.response.ShippingInformationDetails;
            } else if ($scope.bpTree.response.ShippingDeviceDetails != null) {
                locationShippingInfo = $scope.bpTree.response.ShippingInformationDetails;
            } else {
                locationShippingInfo = $scope.shippingInfoDetails;
            }

            if (locationShippingInfo && locationShippingInfo != null) {
                locationShippingInfo.forEach(obj => {
                    allocatedDevices += obj.Devices;
                });
            }

            console.log(allocatedDevices);
            console.log(totalDevices);
            if (allocatedDevices < totalDevices) {
                $scope.modal.msgs.push('Please allocate all devices to proceed.');
            }

            if (!$scope.bpTree.response.ShippingInformationDetails || $scope.bpTree.response.ShippingInformationDetails.length == 0) {
                $scope.modal.msgs.push('Please add locations to proceed.');
            }
        }
        if ($scope.modal.msgs.length > 0) {
            $scope.showModal();
            return false;
        }
        $rootScope.loading = false;
        return true;
    }

    function getFieldErrors(step) {
        var errors = [];
        // wont work for repeatable block
        for (let i = 0; i < step.children.length; i++) {
            if (step.children[i].eleArray[0].propSetMap.required && (step.children[i].response == null || step.children[i].response == '')) {
                if (step.children[i].eleArray[0].propSetMap.label.includes('?'))
                    errors.push(step.children[i].eleArray[0].propSetMap.label)
                else
                    errors.push(step.children[i].eleArray[0].propSetMap.label + ' is required.')
            }
        }
        return errors;
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
                        /*if (shippingDevices.length > 1) {
                            shippingDevices.forEach(obj => {
                                $scope.allocatedDevices += obj.Total;
                            });
                        } else {
                            $scope.allocatedDevices += shippingDevices.Total;
                        }
                        if (shippingInfo) {
                            shippingInfo.forEach(obj => {
                                $scope.totalDevices += obj.Devices;
                            });
                        }*/

                        // $scope.bpTree.response.ShippingDeviceDetails = remoteResp.ShippingDevices;
                        // $scope.bpTree.response.locationOpenId = record.Id;
                        // $("#SILocationInfoBlock").css('display', 'block');
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

}])
function sleep(delay) {
    var start = new Date().getTime();
    while (new Date().getTime() < start + delay);
}