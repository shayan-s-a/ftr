vlocity.cardframework.registerModule.controller('vltStepController', ['$scope','$rootScope', 'bpService', '$q','$window', function ($scope, $rootScope, bpService, $q, $window) {

    const bpPaths = {
        ccs: 'CustomerVOIPRequirements:ConcurrentCallSession',
        handOff: 'CustomerVOIPRequirements:PBXHandOff',
        countOfLocations: 'SelectServiceLocation:CountOfLocations',
        currentLocationId: 'SelectServiceLocation:CurrentLocationId',
        rackMount: 'CustomerVOIPRequirements:RackMountBracket',
        manufacturerName: 'CustomerVOIPRequirements:CPEPBXManufacturerName',
        waiveRouter: 'CustomerVOIPRequirements:WaiveRouter',
        routerModel: 'CustomerVOIPRequirements:CPEPBXModel',
        routerSoftware: 'CustomerVOIPRequirements:CPEPBXSoftwareRel',
        term: 'ServiceTerm',
        ethernetRequired: 'ProductData:EthernetRequired',
        isLit: 'SelectServiceLocation:CurrentLocationLit'

    };
    
    $scope.navigateToCart = function () {
        var dest = '../apex/%vlocity_namespace%__hybridcpq?id=' + $scope.bpTree.response.ContextId;
        if ($rootScope.sforce) {
            $rootScope.sforce.one.navigateToURL(dest,true);
        } else {
            $window.open(dest, "_self");
        }
    }

    $scope.hideModal = function () {
       $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
       $scope.modal.showModal = true;
    }

    $scope.goNext = function (step, finish) {
        console.debug(step);
        $rootScope.loading = true;
        if (stepIsValid(step, finish)){
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
            $rootScope.loading = false;
        } else {
            console.debug('Navigation stopped. Errors found');
        }
    }

    $scope.lastStepName = function () {
        for (var i = $scope.bpTree.children.length - 1; i >= 0; i--) {
            if ($scope.bpTree.children[i].type == 'Step' && $scope.bpTree.children[i].show) {
                return $scope.bpTree.children[i].name;
            }
        }
    }

    function gotoStep (stepName) {
        for (let i=0;i<$scope.bpTree.children.length;i++) {
            if ($scope.bpTree.children[i].name == stepName) {
                $scope.sidebarNav($scope.bpTree.children[i]);
                return;
            }
        }
    }

    function isEthernetRequired() {
        const termList = ['12 Months', '24 Months', '36 Months', '60 Months'];
        const ccs = getElementValue(bpPaths.ccs);
        const term = getElementValue(bpPaths.term);
        const isLit = getElementValue(bpPaths.isLit);
        if (ccs < 23 && !isLit && termList.includes(term)) {
            console.log('Ethernet is required!!');
            console.log('ccs:', ccs);
            console.log('term:', term);
            console.log('isLit:', isLit);
            setElementValue(bpPaths.ethernetRequired, 'Yes');
            return true;
        } else {
            console.log('Ethernet is NOT required!!');
            console.log('ccs:', ccs);
            console.log('term:', term);
            console.log('isLit:', isLit);
            setElementValue(bpPaths.ethernetRequired, 'No');
            return false;
        }
    }

    function stepIsValid (step, finish) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };
         
        if (step.name == 'SelectServiceLocation') {
            if (!getElementValue(bpPaths.currentLocationId)) {
                $scope.modal.msgs.push('Service location is required.');
            }

            if ($scope.modal.msgs.length == 0) {
                if (getElementValue('isBundle')) {
                    let osData = getElementValue('OSData');
                    if (!Array.isArray(osData)) {
                        osData = [osData];
                    }
                    // check if it's already in there, 1 per service account
                    for (let i=0; i<osData.length;i++) {
                        if (osData[i].ServiceAccountId == getElementValue(bpPaths.currentLocationId)) {
                            idx = i;
                        }
                    }
                    
                    setElementValue('CurrentProduct', null);
                    setElementValue('CurrentProduct', osData[idx]);
                }
            }

        } else if (step.name == 'VOIPQualification') {
            
            // if qualification has an Id, means they selected an existing one. Allow them to proceed.
            if (!getElementValue('VOIPQualifications')[0]) {
                if (getElementValue('Qualification.success') != true) {
                    $scope.modal.msgs.push('NPA/NXX Qualification is required.');

                } else if (getElementValue('VoipQualUpsertResult.success') != true) {
                    $scope.modal.msgs.push('Please add the NPA/NXX for this location.');
                }
            }
            
        } else if (step.name == 'CustomerVOIPRequirements') {

            if (!getElementValue(bpPaths.ccs)) {
                $scope.modal.msgs.push('Concurrent Call Sessions (CCS) is required.');

                // if handoff = SIP, CCS must be 8-5000
            } else if (getElementValue(bpPaths.handOff) == 'SIP' && (parseInt(getElementValue(bpPaths.ccs)) < 8 || parseInt(getElementValue(bpPaths.ccs)) > 5000)) {
                $scope.modal.msgs.push('Concurrent Call Sessions must be between 8 and 5000.');

                // if handoff = PRI, CCS must be 8-5000
            } else if (getElementValue(bpPaths.handOff) == 'PRI' && (parseInt(getElementValue(bpPaths.ccs)) < 8 || parseInt(getElementValue(bpPaths.ccs)) > 46)) {
                $scope.modal.msgs.push('Concurrent Call Sessions must be between 8 and 46.');

                // if handoff = Analog, CCS must be 8-5000
            } else if (getElementValue(bpPaths.handOff) == 'Analog' && (parseInt(getElementValue(bpPaths.ccs)) < 8 || parseInt(getElementValue(bpPaths.ccs)) > 23)) {
                $scope.modal.msgs.push('Concurrent Call Sessions must be between 8 and 23.');

            }
            if (getElementValue(bpPaths.handOff) != 'SIP' && !getElementValue(bpPaths.rackMount)) {
                $scope.modal.msgs.push('Rack mount bracket size is required.');

            }
            if (getElementValue(bpPaths.handOff) == 'SIP' && getElementValue(bpPaths.waiveRouter) == 'Yes' && (!getElementValue(bpPaths.manufacturerName) || !getElementValue(bpPaths.routerModel) || !getElementValue(bpPaths.routerSoftware))) {
                $scope.modal.msgs.push('Router details are required.');
                
            }
            if ($scope.modal.msgs.length == 0) {
                isEthernetRequired()
                // $scope.modal.isError = false;
                // $scope.modal.cancelLabel = 'Cancel';
                // $scope.modal.continueLabel = 'Proceed';
                // $scope.modal.title = 'Acknowledgment';
                // $scope.modal.msgs.push('Customer should select/have any one of the Frontier Ethernet Services at this location');
            } 

        } else if (step.name == 'DIARequired') {
            // if they have an existing DIA order items at this service location... or if there is already one on this quote...
            // swap if statement with below if they do not want to check against in flight DIAs
            // if (getCountOfRecordsAtCurrentLocaiton('ProductCode', 'ENT_ETH_EIA_0002') == 0) {
            if (getElementValue('AddChildProductsResult:CheckIfProductsExist:ExistingDIAs') == null && getCountOfRecordsAtCurrentLocaiton('ProductCode', 'ENT_ETH_EIA_0002') == 0) {
                $scope.modal.msgs.push('Please add a DIA for this location.')
            }
        } else if (step.name == $scope.lastStepName()) {

            // if (step.name == 'ManagedFirewallQualifiication'){
            //     let q1 = getElementValue('ManagedFirewallQualifiication:Question1');
            //     let q2 = getElementValue('ManagedFirewallQualifiication:Question2');
            //     let q3 = getElementValue('ManagedFirewallQualifiication:Question3');
            //     let q4 = getElementValue('ManagedFirewallQualifiication:Question4');

            //     if ((q1 == 'No' && q2 == 'No' && q3 == 'No' && q4 == 'No')){

            //         $scope.modal.isError = false;
            //         $scope.modal.cancelLabel = 'Cancel';
            //         $scope.modal.continueLabel = 'Proceed';
            //         $scope.modal.title = 'Acknowledgment';
            //         $scope.modal.msgs.push('You are Qualified! Managed Firewall Add-on will be auto added to the Cart.');
            //     }

            // }
            if ($scope.modal.msgs.length == 0) {
                $scope.bpTree.response.StepLoopCount++;
                var numberOfLocations = parseInt(getElementValue(bpPaths.countOfLocations));
                if (numberOfLocations > 1) {
                    gotoStep('SelectServiceLocation');
                    $rootScope.loading = false;
                }
            }
        }
       

        if ($scope.modal.msgs.length > 0) {
            $rootScope.loading = false;
            $scope.showModal();
            return false;
        }
        return true;
    }

    // function getCCSData() {
    //     const ccs = Number(getElementValue(bpPaths.ccs));
    //     const serviceAccountId = getElementValue(bpPaths.currentLocationId);
    //     var input = {
    //         bundleName: 'GetCCSData',
    //         objectList: {
    //             PBXHandOff: getElementValue(bpPaths.handOff)
    //         },
    //         filesMap: {}
    //     };
    //     var configObj = {
    //         sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
    //         sMethodName: 'invokeInboundDR',
    //         input: angular.toJson(input),
    //         options:angular.toJson({})
    //     };
    //     return $q(function(resolve, reject) {
    //         bpService.OmniRemoteInvoke(configObj).then(function(result) {
    //             var remoteResp = angular.fromJson(result);
    //             if(remoteResp && remoteResp.error == 'OK') {
    //                 console.log(remoteResp);
    //                 if (remoteResp.IBDRresp.returnResultsData != null) {
    //                     var configList = remoteResp.IBDRresp.returnResultsData.Config;
    //                     for (let i = 0; i< configList.length; i++) {
    //                         let ccsRange = configList[i].CCS.split("-");
    //                         let x = Number(ccsRange[0]);
    //                         let y = Number(ccsRange[1]);
    //                         if (ccs >= x && ccs <= y) {
    //                             setElementValue('ConcurrentCallSessionValues', configList[i]);
    //                             resolve(configList[i]);
    //                         }
    //                     }
    //                 }
    //             } else {
    //                 resolve(remoteResp);
    //                 console.error('Error in calling DR '+ remoteResp);
    //             }
    //         }).catch(function (error) {
    //             console.error('Error while calling DR ' + error);
    //             reject(error);
    //         });
    //     });
    // }

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

    function getCountOfRecordsAtCurrentLocaiton (field, filterValue) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue(field, item) == filterValue && getElementValue('%vlocity_namespace%__ServiceAccountId__c.value', item) == getElementValue(bpPaths.currentLocationId)) {
                count += parseInt(getElementValue('Quantity.value', item));
            }
        });
        return count;
    }

    function getCountOfRecordsList(field, fitlerValues) {
        var count = 0;
        for (let i=0; i< fitlerValues.length; i++) {
            count += getCountOfRecords(field, fitlerValues[i]);
        }
        return count;
    }

    function getRecordIds (field, filterValue) {
        var idList = [];
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue(field, item) == filterValue) {
                idList.push({ Id: getElementValue('Id.value', item) });
            }
        });
        return idList;
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

}])