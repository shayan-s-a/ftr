vlocity.cardframework.registerModule.controller('vltStepController', ['$scope','$rootScope','$window', function ($scope, $rootScope, $window) {
    const meetingsAndWebinarProducts = [
        'UCF_COLLAB_10',
        'UCF_COLLAB_100',
        'UCF_COLLAB_200',
        'UCF_COLLAB_25',
        'UCF_COLLAB_300',
        'UCF_COLLAB_500',
        'UCF_WEBINAR_100',
        'UCF_WEBINAR_1000',
        'UCF_WEBINAR_500'
    ];

    $scope.lastStepName = getLastStepName();
    
    $scope.navigateToCart = function () {
        var dest = '/apex/%vlocity_namespace%__hybridcpq?id=' + $scope.bpTree.response.ContextId;
        if ($rootScope.sforce) {
            $rootScope.sforce.one.navigateToURL(dest,true);
        } else {
            $window.open('..'+dest, "_self");
        }
    }

    $scope.hideModal = function () {
       $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
       $scope.modal.showModal = true;
    }

    $scope.goNext = function (step) {
        // console.log(step);
        if(stepIsValid(step)) {
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
        }
    }

    function getLastStepName () {
        for (var i = $scope.bpTree.children.length - 1; i >= 0; i--) {
            if ($scope.bpTree.children[i].type == 'Step') {
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

    function stepIsValid (step) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };

        if (step.name == 'SelectServiceLocation') {
            if (!$scope.bpTree.response[step.name]['CurrentLocationId']) {
                $scope.modal.msgs.push('Service location is required.');
            }
            if (!$scope.bpTree.response[step.name]['PrimaryLocationId']) {
                $scope.modal.msgs.push('Primary location needs to be set.');
            }
            if (!$scope.bpTree.response[step.name]['ServiceTerm']) {
                $scope.modal.msgs.push('Service term is required.');
            }
            // if no errors, set term
            // if ($scope.modal.msgs.length == 0) {
            //     $scope.bpTree.response.osData.UCFTerm = $scope.bpTree.response[step.name]['ServiceTerm'];
            // }

               if ($scope.modal.msgs.length == 0) {
                if (getElementValue('isBundle')) {
                    let osData = getElementValue('osData');
                    if (!Array.isArray(osData)) {
                        osData = [osData];
                    }
                    var idx = 0;
                    // check if it's already in there, 1 per service account
                    for (let i=0; i<osData.length;i++) {
                        if (osData[i].ServiceAccountId == $scope.bpTree.response[step.name]['CurrentLocationId']) {
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

        }
        else if (step.name == 'LicSelection') {
            var analogLicenseCount = getCountOfRecords('ProductCode', 'UCF_ANALOG_LIC');
            if (analogLicenseCount > 0) {
                $scope.modal.isError = false;
                $scope.modal.cancelLabel = 'Cancel';
                $scope.modal.continueLabel = 'Proceed';
                $scope.modal.title = 'Acknowledgment';
                $scope.modal.msgs.push('ATA port is required for Analog licenses.');
            }
        } else if (step.name == 'PhoneSelection') {
            $scope.numberOfBasicLicenses = getCountOfRecords('ProductCode', 'UCF_BASIC_LIC');
            $scope.numberOfLicenses = getCountOfRecords('Product2.%vlocity_namespace%__Type__c', 'License');
            $scope.numberOfPhones = getCountOfRecords('Product2.%vlocity_namespace%__SubType__c', 'VOIP Phone');
            var existingCharges = {
                InstallationCharges: getRecordIds('ProductCode', 'UCF_INST_CHG_PH'),
                WarrantyCharges: getRecordIds('ProductCode', 'UCF_WRNTY_PH'),
                E911Charges: getRecordIds('ProductCode', 'UCF_ADDL_E911'),
                SwitchInstallationCharges: getRecordIds('ProductCode', 'UCF_INST_CHG_SWITCH')
            };
            var phoneCount = {
                Purchased: getCountOfPhonesByAttribute('ATTR_BUYING_OPTION', 'Purchase'),
                Rented: getCountOfPhonesByAttribute('ATTR_BUYING_OPTION', 'Rent'),
                TotalQuantity: $scope.numberOfPhones
            };
            setElementValue('PhoneCount', phoneCount);
            setElementValue('GetExistingCharges', existingCharges);
            if ($scope.numberOfBasicLicenses > $scope.numberOfPhones) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('The number of basic licenses in the cart is greater than the number of phones.');
            } else if ($scope.numberOfLicenses < $scope.numberOfPhones) {
                $scope.modal.isError = false;
                $scope.modal.cancelLabel = 'Cancel';
                $scope.modal.continueLabel = 'Proceed';
                $scope.modal.title = 'Acknowledgment';
                $scope.modal.msgs.push('The number of licenses in the cart is less than the number of phones.');
            } 
        } else if (step.name == 'AddOnSelection') {
            $scope.numberOfExecLicenses = getCountOfRecords('ProductCode', 'UCF_EXEC_LIC');
            $scope.numberOfMeetingsAndWebinars = getCountOfRecordsList('ProductCode', meetingsAndWebinarProducts);
            if ($scope.numberOfMeetingsAndWebinars > $scope.numberOfExecLicenses) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('Meetings and Webinars must have an Executive license.');
            }
        } else if (step.name == 'SwitchSelection') {
            $scope.numberOfSwitches = getCountOfRecords('Product2.%vlocity_namespace%__Type__c', 'Switch');
            setElementValue('SwitchCount', $scope.numberOfSwitches);
        } else if (step.name == $scope.lastStepName) {
            var numberOfLocations = parseInt(getElementValue('SelectServiceLocation.CountOfLocations'));
            if (numberOfLocations > 1) {
                gotoStep('SelectServiceLocation');
            }
        }

        if ($scope.modal.msgs.length > 0) {
            $scope.showModal();
            return false;
        }
        return true;
    }

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

    function getCountOfPhonesByAttribute (attributeName, filterValue) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue('Product2.%vlocity_namespace%__SubType__c', item) == 'VOIP Phone') {
                var attributeCategories = getElementValue('attributeCategories', item);
                if (attributeCategories && attributeCategories.records) {
                    var skipItem = false;
                    // check if its a discount or add on first, if so, skip item and dont add to count
                    for (let i=0; i < attributeCategories.records.length; i++) {
                        if (attributeCategories.records[i].productAttributes && attributeCategories.records[i].productAttributes.records) {
                            var attributes = attributeCategories.records[i].productAttributes.records;
                            for (let j=0 ; j < attributes.length; j++) {
                                if ((attributes[j].code == 'ATTR_IS_DISCOUNT' || attributes[j].code == 'ATTR_IS_ADD_ON') && attributes[j].userValues == 'Yes') {
                                   skipItem = true;
                                }
                            }
                        }
                    }
                    if (!skipItem) {
                        for (let i=0; i < attributeCategories.records.length; i++) {
                            if (attributeCategories.records[i].productAttributes && attributeCategories.records[i].productAttributes.records) {
                                var attributes = attributeCategories.records[i].productAttributes.records;
                                for (let j=0 ; j < attributes.length; j++) {
                                    if (attributes[j].code == attributeName && attributes[j].userValues == filterValue) {
                                        count += parseInt(getElementValue('Quantity.value', item));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });
        return count;
    }

    function getCountOfRecords (field, filterValue) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue(field, item) == filterValue) {
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

    // function callDR(className, methodName, input, iTimeout) {
    //     var option = {};
    //     var configObj = {
    //         sClassName: className,      // 'DefaultDROmniScriptIntegration'
    //         sMethodName: methodName,    //'invokeOutboundDR'
    //         input:angular.toJson(input),
    //         options:angular.toJson(option),
    //         iTimeout:iTimeout,
    //     };
    //     bpService.OmniRemoteInvoke(configObj).then(function(result) {
    //         var remoteResp = angular.fromJson(result);
    //         if(remoteResp && remoteResp.error == 'OK') {
                
    //         } else {
    //             console.error('Error in calling DR' + , error);
    //         }
    //     }).catch(function (error) {
    //         console.error('Error in calling DR' + , error);
    //     });
    // }

}])