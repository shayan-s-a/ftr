vlocity.cardframework.registerModule.controller('RcShippingInfoShipmentDetailsController', ['$scope', '$window', '$timeout', '$filter', '$rootScope', '$document', 'bpService', '$q', function ($scope, $window, $timeout, $filter, $rootScope, $document, bpService, $q) {

    $scope.toggleEditMode = function (record) {
        $scope.bpTree.shipCount = document.getElementById(record.Id).value;
        if (record.ShipCount == undefined) {
            record.ShipCount = 0;
        }
        if (Number($scope.bpTree.shipCount) > record.Total) {
            document.getElementById('errorMessage').textContent = 'Ship count can not be greater then the Total.';
            $scope.bpTree.shipCount = ''; // Clear the input
            return

        }
        if (Number($scope.bpTree.shipCount) > (record.Allocated + record.Remaining)) {
            document.getElementById('errorMessage').textContent = 'Ship count should be less then or equals to Remaining.';
            $scope.bpTree.shipCount = ''; // Clear the input
            return
        }
        // if (Number($scope.bpTree.shipCount) >  record.Remaining) {
        //     document.getElementById('errorMessage').textContent = 'The inserted ship count is exceeding total remaining limit.';
        //     $scope.bpTree.shipCount = ''; // Clear the input
        //     return
        // }
        if (((record.Allocated - record.ShipCount) + Number($scope.bpTree.shipCount)) >  record.Total) {
            document.getElementById('errorMessage').textContent = 'Ship count should be less then or equals to overall Remaining devices.';
            $scope.bpTree.shipCount = ''; // Clear the input
            return
        }
        const regex = /^[0-9]+$/;
        const inputValue = Number($scope.bpTree.shipCount);
        debugger
        if (!regex.test(inputValue)) {
            document.getElementById('errorMessage').textContent = 'Please enter a valid number (no special characters allowed).';
            $scope.bpTree.shipCount = ''; // Clear the input
            return
        } else {
            document.getElementById('errorMessage').textContent = '';
        }
        $scope.bpTree.response.ShippingDeviceDetails = [];
        console.log('Quote Location  ' + $scope.bpTree.response.Locations[0].Value);
        let errorFields = [];
        debugger
        var configObj = {
            sClassName: '%vlocity_namespace%.IntegrationProcedureService',
            sMethodName: 'RingCentral_UpdateShippingDeviceInfo',
            input: angular.toJson({ Id: record.Id, OrderProductId: record.OrderProductId, OldShipCount : record.ShipCount, ShipCount: Number($scope.bpTree.shipCount), ShippingInfoId: $scope.bpTree.shippingInfoId }),
            //input: angular.toJson({ Id: record.Id, OrderProductId: record.OrderProductId, ShipCount: (record.ShipCount + Number($scope.bpTree.shipCount)), ShippingInfoId: $scope.bpTree.shippingInfoId }),
            options: angular.toJson({})
        };
        let conf = configObj;

        $rootScope.loading = true;
        bpService.OmniRemoteInvoke(configObj).then(function (result) {
            console.info('Result: ', JSON.parse(result));
            $scope.bpTree.response.ShippingDeviceDetails = JSON.parse(result).IPResult.ShippingDevices;

            //Update the shipping information
            getShippingInfoDetails();

            $rootScope.loading = false;
        });

        // executeRemoteAction(configObj);


        $scope.addErrorMsg = null;
    }
    function getUpdatedShippingInfo() {
        let errorFields = [];
        var configObj = {
            sClassName: '%vlocity_namespace%.IntegrationProcedureService',
            sMethodName: 'RingCentral_GetupdatedShippingInfo',
            input: angular.toJson({ ContextId: $scope.bpTree.ContextId }),
            options: angular.toJson({})
        };
        let conf = configObj;
        executeRemoteAction(configObj);
    }
    function getShippingInfoDetails() {
        var input = {
            DRParams: { OrderId: $scope.bpTree.ContextId },
            Bundle: 'DR_GetShippingInfoByOrderIdV5'
        };

        var configObj = {
            sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
            sMethodName: 'invokeOutboundDR',
            input: angular.toJson(input),
            options: angular.toJson({ "useQueueableApexRemoting": false })
        };

        // executeRemoteAction(configObj);

        bpService.OmniRemoteInvoke(configObj).then(function (result) {
            console.info('ShippingInformationDetails: ', JSON.parse(result));
            $scope.bpTree.response.ShippingInformationDetails = JSON.parse(result).OBDRresp.ShippingInformationDetails;
        });

    }
    function executeRemoteAction(configObj, record) {
        debugger
        let shippingInfoDetails = [];
        $rootScope.loading = true;
        return $q(function (resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(function (result) {
                var remoteResp = angular.fromJson(result);
                console.log(configObj.sMethodName + ' result:', remoteResp);
                if (remoteResp && remoteResp.IPResult && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.IPResult;
                    if (configObj.sMethodName == 'RingCentral_UpdateShippingDeviceInfo') {

                        $scope.bpTree.response.ShippingDeviceDetails = remoteResp.ShippingDevices;
                    }
                    //  if (configObj.sMethodName == 'RingCentral_GetupdatedShippingInfo') {
                    //     debugger
                    //     $scope.bpTree.response.ShippingInformationDetails = remoteResp.ShippingInformationDetails;
                    //     $scope.bpTree.response.ShippingInformation.ShippingInformationDetails = remoteResp.ShippingInformationDetails;

                    //     //$scope.bpTree.response.ShippingInformationDetails = remoteResp.ShippingInformationDetails;
                    // }
                    $scope.shippingaddresses = remoteResp;
                    if (remoteResp.success == false) {
                        if (remoteResp.result[0].errors)
                            alert(JSON.stringify(remoteResp.result[0].errors));
                        $rootScope.loading = false;
                        reject(remoteResp);
                    }
                    //setElementValue('ShippingInformationDetails', remoteResp.ShippingInformationDetails);
                    $rootScope.loading = false;
                } else if (remoteResp && remoteResp.OBDRresp && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.OBDRresp;
                    if (configObj.sMethodName == 'invokeOutboundDR') {
                        // if (configObj.sMethodName == 'RingCentral_GetupdatedShippingInfo') {
                        debugger
                        // shippingInfoDetails = remoteResp.ShippingInformationDetails;
                        $scope.bpTree.response.ShippingInformationDetails = remoteResp.ShippingInformationDetails;
                        // $scope.bpTree.response.ShippingInformation.ShippingInformationDetails = remoteResp.ShippingInformationDetails;

                        //$scope.bpTree.response.ShippingInformationDetails = remoteResp.ShippingInformationDetails;
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
            console.log($scope.bpTree);

        });

    }
    $scope.myFunct = function (keyEvent) {
        if (keyEvent.which > 31 && (keyEvent.which < 48 || keyEvent.which > 57)) {
            event.preventDefault();
            return false;
        }
        return true;
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

}]);