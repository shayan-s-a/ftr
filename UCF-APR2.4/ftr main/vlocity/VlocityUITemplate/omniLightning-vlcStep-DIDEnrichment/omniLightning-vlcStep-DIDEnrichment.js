vlocity.cardframework.registerModule.controller('vltStepController', ['$scope','$rootScope', 'bpService', '$timeout','$route', function ($scope, $rootScope, bpService, $timeout, $route) {

    $scope.bpTree.response.E911Type = '';
    
    const bpPaths = {
        countOfLocations: 'SelectServiceLocation:CountOfLocations',
        currentLocationId: 'SelectServiceLocation:CurrentLocationId',
        numberOfDIDLocations: 'SelectServiceLocation:NumberOfDIDLocations',
        currentDIDLocationCount: 'CurrentDIDLocationCount'

    };

    $scope.lastStepName = getLastStepName();

    if ($scope.child.name == 'SelectServiceLocation') {
        $scope.$watch('bpTree.response.SelectServiceLocation.userCanEditFormula', function(newVal,oldVal){
            if (newVal == oldVal) return; 
            if (newVal == false) {
                setElementValue('SelectServiceLocation:SelectNewOrEixstingDID', 'Existing');
            } else if (newVal == true) {
                setElementValue('SelectServiceLocation:SelectNewOrEixstingDID', 'New');
            }
        });
    }
    
    $scope.exit = function () {
        var dest = '/' + $scope.bpTree.response.ContextId;
        $rootScope.sforce.one.navigateToURL(dest,true);
    }

    $scope.hideModal = function () {
       $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
       $scope.modal.showModal = true;
    }

    $scope.getData = function(step) {
        
    }

    // watch for the page to load
    $scope.$watch('child.bAccordionActive', function(newValue, oldValue) {
        if (newValue !== oldValue && $scope.child.bAccordionOpen) {

            if ($scope.child.name == 'UNILocationDetails') {
                // execute the dataraptor
                $timeout(function() {
                    $('#GetLineItemsForSIPOrdering').click();  
                }, 0);
            } else if ($scope.child.name == 'Configure911') {
                // execute the dataraptor
                $timeout(function() {
                    $('#GetDID911Details').click();  
                }, 0);
            } else if ($scope.child.name == 'DIDLocationDetails') {
                // execute the dataraptor
                $timeout(function() {
                    $('#GetDIDLocationDetailsOnInit').click();  
                }, 0);
            }
            
        }
    });

    $scope.goNext = function (step) {
        // console.log('current step:',step);
        $rootScope.loading = true;
        if (stepIsValid(step)){
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
            $rootScope.loading = false;
        } else {
            console.log('Navigation stopped. Errors found');
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
                $scope.nextRepeater(i, i+1);
                $rootScope.loading = false;
                break;
            }
        }
    }

    function nullifyStep (stepName) {
        for (let i=0;i<$scope.bpTree.children.length;i++) {
            if ($scope.bpTree.children[i].name == stepName) {
                $scope.nullifyResponse($scope.bpTree.children[i]);
            }
        }
    }

    function stepIsValid (step, exit) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };

        if (step.name == 'SelectServiceLocation') {
            if (!getElementValue(bpPaths.currentLocationId)) {
                $scope.modal.msgs.push('A Service Location is required.');
            }

            if (getElementValue('SelectServiceLocation:SelectNewOrEixstingDID') == 'Existing') {
                if (!getElementValue('SelectedDIDLocation')) {
                    $scope.modal.msgs.push('Please select a DID Location.');
                }

            } else if (getElementValue('SelectServiceLocation:SelectNewOrEixstingDID') == 'New') { 
                if (getElementValue('SelectServiceLocation:DIDLocationName') == null || getElementValue('SelectServiceLocation:DIDLocationName') == '') {
                    $scope.modal.msgs.push('DID Location Name is required.');
                }
                
            }


            if ($scope.modal.msgs.length == 0) {
                nullifyStep('Configure911');
                $rootScope.$broadcast("ClearRepeatableBlock", 'UNIDetails');
                $rootScope.$broadcast("ClearRepeatableBlock", 'SIPDetails');
                // nullifyStep('DIDLocationDetails');
                // $scope.bpTree.response.Configure911.ELINERL.length = 0;
            }
            
        } else if (step.name == 'DIDLocationDetails') {
            
            // if (!getElementValue('VOIPQualifications')) {

            //     if (getElementValue('Qualification.success') != true) {
            //         $scope.modal.msgs.push('An NPA/NXX is required.');

            //     } else if (getElementValue('VoipQualUpsertResult.success') != true) {
            //         $scope.modal.msgs.push('Please add the NPA/NXX for this location.');
            //     }
            // }
            if (getElementValue('SelectServiceLocation.userCanEditFormula') == true) {
                
                
                
                if (getElementValue('DIDNumbers') != null && getElementValue('DIDNumbers') != '') {
                    if (getElementValue('DIDLocationDetails:BTN') == null || getElementValue('DIDLocationDetails:BTN') == '') {
                        $scope.modal.msgs.push('BTN is required.');
                    } else if (hasValidNPANXX('DIDLocationDetails:BTN')) {
                        $scope.modal.msgs.push('BTN must match a qualified NPA/NXX.');
                    }
                }
                if (getElementValue('DIDLocationDetails:DIDTestNumber') != null && getElementValue('DIDLocationDetails:DIDTestNumber') != '') {
                    if (hasValidNPANXX('DIDLocationDetails:DIDTestNumber')) {
                        $scope.modal.msgs.push('Test number must match a qualified NPA/NXX.');
                    }
                }
                if (getElementValue('DIDLocationDetails:InternationalDialing') == 'Yes') {
                    if (getElementValue('DIDLocationDetails:InternationalDialingOptions') == null || getElementValue('DIDLocationDetails:InternationalDialingOptions') == '') {
                        $scope.modal.msgs.push('International Dialing Option is required.');
                    }
                }
                if (getElementValue('DIDLocationDetails:NumberOfDIDs') != 0) {
                    if (getElementValue('DIDLocationDetails:NumberOfDIDs') == null || getElementValue('DIDLocationDetails:NumberOfDIDs') == '') {
                        $scope.modal.msgs.push('Number of DID\'s for this Location is required.');
                    }
                }
                if (getElementValue('DIDLocationDetails:MDN') == null || getElementValue('DIDLocationDetails:MDN') == '') {
                    $scope.modal.msgs.push('Main Directory Number is required.');
                } else if (hasValidNPANXX('DIDLocationDetails:MDN')) {
                    $scope.modal.msgs.push('Main Directory Number must match a qualified NPA/NXX.');
                }
                /* if (getElementValue('DIDLocationDetails:NumberOfCallPaths') == null || getElementValue('DIDLocationDetails:NumberOfCallPaths') == '') {
                     $scope.modal.msgs.push('# of call paths for this DID Location is required.');
                 }
                 if (getElementValue('DIDLocationDetails:CallerIdPresentation') == null || getElementValue('DIDLocationDetails:CallerIdPresentation') == '') {
                     $scope.modal.msgs.push('Incoming caller ID presentation is required.');
                 }
                 if (getElementValue('DIDLocationDetails:DigitsSentToCustomer') == null || getElementValue('DIDLocationDetails:DigitsSentToCustomer') == '') {
                     $scope.modal.msgs.push('Digits sent to customer is required.');
                 }
                 if (getElementValue('DIDLocationDetails:ConnectLineIdScreening') == null || getElementValue('DIDLocationDetails:ConnectLineIdScreening') == '') {
                     $scope.modal.msgs.push('Connect line ID screening is required.');
                 }
                 if (getElementValue('DIDLocationDetails:InternationalDialing') == null || getElementValue('DIDLocationDetails:InternationalDialing') == '') {
                     $scope.modal.msgs.push('International Dialing is required.');
                 } */
            }

            if($scope.bpTree.response.VOIPQualifications && $scope.bpTree.response.VOIPQualifications.length > 0 && $scope.bpTree.response.DIDLocationDetails.MDN != null && $scope.bpTree.response.DIDLocationDetails.MDN != '' ){
                let mainNPA = $scope.bpTree.response.DIDLocationDetails.MDN.substring(0,3); 
                let mainNXX = $scope.bpTree.response.DIDLocationDetails.MDN.substring(3,6);
                console.log("mainNPA: ", mainNPA);
                console.log("mainNXX: ", mainNXX);
                for (let i=0; i < $scope.bpTree.response.VOIPQualifications.length; i++) {
                    if($scope.bpTree.response.VOIPQualifications[i].NXX == mainNXX && $scope.bpTree.response.VOIPQualifications[i].NPA == mainNPA){
                        $scope.bpTree.response.E911Type = $scope.bpTree.response.VOIPQualifications[i].E911Type;
                        break;
                    }
                }
                for (let j=0; j < $scope.bpTree.response.DIDNumbers.length; j++) {
                    if($scope.bpTree.response.DIDNumbers[j].DIDNumber == scope.bpTree.response.DIDLocationDetails.MDN){
                        $scope.bpTree.response.DIDLocationDetails.DIDNumberInfo = $scope.bpTree.response.DIDNumbers[j].DIDNumberInfo;
                        break;
                    }
                }
            } else if($scope.bpTree.response.VOIPQualifications && $scope.bpTree.response.VOIPQualifications.E911Type){
                $scope.bpTree.response.E911Type = $scope.bpTree.response.VOIPQualifications.E911Type;
            }

            if ($scope.modal.msgs.length == 0) {
                $rootScope.$broadcast("ClearRepeatableBlock", 'ELINERL');
            }
            
        } else if (step.name == 'Configure911') {

            if (getElementValue('SelectServiceLocation.userCanEdit') == true) {

                if (getElementValue('Configure911:x911Option') == null || getElementValue('Configure911:x911Option') == '') {
                    $scope.modal.msgs.push('911 Option is required.');
                }
                if (getElementValue('Configure911:FTR911Provider') == null || getElementValue('Configure911:FTR911Provider') == '') {
                    $scope.modal.msgs.push('FTR 911 Provider is required.');
                }

                if (getElementValue('Configure911:x911Option') == 'Main Designated #') {
                    
                    if (getElementValue('Configure911:MainDesignatedSection:MainDesignatedName') == null || getElementValue('Configure911:MainDesignatedSection:MainDesignatedName') == '') {
                    $scope.modal.msgs.push('Name is required.');
                    }
                    if (getElementValue('Configure911:MainDesignatedSection:MainDesignatedNumber') == null || getElementValue('Configure911:MainDesignatedSection:MainDesignatedNumber') == '') {
                        $scope.modal.msgs.push('Main designated number is required.');
                    } else if (hasValidNPANXX('Configure911:MainDesignatedSection:MainDesignatedNumber')) {
                        $scope.modal.msgs.push('Main Designated Number must match a qualified NPA/NXX.');
                    }
                    //if (getElementValue('Configure911:MainDesignatedSection:MainDesignatedAddress') == null || getElementValue('Configure911:MainDesignatedSection:MainDesignatedAddress') == '') {    // Commenting to remove Validation until the proper validation fix is developed - avv335
                    //$scope.modal.msgs.push('Address is required.');
                    //}
                    
                } else if (getElementValue('Configure911:x911Option') == 'ELIN/ERL') {

                    let elin = getElementValue('Configure911:ELINERL');
                    let missingNumber = false;
                    if (angular.isArray(elin)) {
                        angular.forEach(elin, (item, key)=>{
                            if (item && item.DIDNumber == null) {
                                missingNumber = true;
                            }
                        });
                    } else {
                        if (elin.DIDNumber == null || elin.DIDNumber == '') missingNumber = true;
                    }
                    if (missingNumber) $scope.modal.msgs.push('DID number is required.');
                }
            }

            // make sure there are no errors
            if ($scope.modal.msgs.length == 0) {

                // // save 911 info
                // $timeout(function() {
                //     $('#Save911Details').click();  
                //     // $scope.nullifyResponse();
                // }, 0);
                if (getElementValue('Finished') != true) {
                    if (getElementValue('SelectServiceLocation:SelectNewOrEixstingDID') == 'New') {
                        // if its a new DID Location, loop through the count, else go back to the first page
                        var numberOfDIDLocations = parseInt(getElementValue(bpPaths.numberOfDIDLocations));
                        numberOfDIDLocations--;
                        var currentDIDLocationCount = parseInt(getElementValue(bpPaths.currentDIDLocationCount));
                        currentDIDLocationCount++;
                        setElementValue(bpPaths.currentDIDLocationCount, currentDIDLocationCount);

                        if (numberOfDIDLocations >= currentDIDLocationCount) {
                            // nullifyStep('DIDLocationDetails');
                            gotoStep('CreateDIDLocationDetailRecord');
                        } else {
                            // gotoStep('GetServiceAccounts');
                            $route.reload();
                        }
                    } else {
                        // gotoStep('GetServiceAccounts');
                        $route.reload();
                    }
                }
                
            }

                // $scope.modal.isError = false;
                // $scope.modal.cancelLabel = 'Cancel';
                // $scope.modal.continueLabel = 'Proceed';
                // $scope.modal.title = 'Acknowledgment';
                // $scope.modal.msgs.push('Customer should select/have any one of the Frontier Ethernet Services at this location');

        } else if (step.name == 'UNILocationDetails') {
            if (getElementValue('SelectServiceLocation.userCanEdit') == true) {

                const uniDetail = getElementValue('UNILocationDetails.UNIDetails');
                console.log(step);
                if (Array.isArray(uniDetail)) {
                    angular.forEach(uniDetail, function(uni, index) {
                        $scope.evaluateRequiredFieldsForUNI(uni, index);
                    });
                } else {
                    $scope.evaluateRequiredFieldsForUNI(uniDetail);
                }

                $scope.modal.msgs = [...new Set($scope.modal.msgs)];

            }

            
        } else if (step.name == 'EVCLocationDetails') {
            // if (parseInt(getElementValue('SelectServiceLocation:CountOfLocations')) > 1) {
                gotoStep('GetServiceAccounts');
            // }
        }

        if ($scope.modal.msgs.length > 0) {
            $rootScope.loading = false;
            $scope.showModal();
            return false;
        }
        return true;
    }

    $scope.finish = function (step) {
        setElementValue('Finished', true);
        $scope.goNext(step);
    }

    $scope.evaluateRequiredFieldsForUNI = function(obj) {

        // PRI/T1 specific validations
        if (obj.IADConfiguration.IADHandoff == 'PRI/T1' || obj.IADConfiguration.IADHandoff == 'Both') {

            // IAD PRI/T1 Optional Accessories/Kits
            if (obj.IADAccessoriesKits.Cable == null || obj.IADAccessoriesKits.Cable == '') {
                $scope.modal.msgs.push('Cable is required.');
            }
            if (obj.IADAccessoriesKits.CableQuantity == null || obj.IADAccessoriesKits.CableQuantity == '') {
                $scope.modal.msgs.push('Cable Quantity is required.');
            }

            // IAD PRI/T1 Trunk Information
            if (obj.IADTrunkInformation.NumberOfHandoffs == null || obj.IADTrunkInformation.NumberOfHandoffs == '') {
                $scope.modal.msgs.push('Number of Handoffs is required.');
            }
            if (obj.IADTrunkInformation.HandoffType == null || obj.IADTrunkInformation.HandoffType == '') {
                $scope.modal.msgs.push('Handoff Type is required.');
            } else {
                
                // if the Handoff is populated, check the type for additional required fields
                if (obj.IADTrunkInformation.HandoffType == 'T1') {
                    if (obj.IADTrunkInformation.Framing == null || obj.IADTrunkInformation.Framing == '') {
                        $scope.modal.msgs.push('Framing is required.');
                    }
                    if (obj.IADTrunkInformation.Coding == null || obj.IADTrunkInformation.Coding == '') {
                        $scope.modal.msgs.push('Coding is required.');
                    }
                    if (obj.IADTrunkInformation.StartDialMethod == null || obj.IADTrunkInformation.StartDialMethod == '') {
                        $scope.modal.msgs.push('Supervision/Start Dial Method is required.');
                    }
                    if (obj.IADTrunkInformation.NumberOfChannels == null || obj.IADTrunkInformation.NumberOfChannels == '') {
                        $scope.modal.msgs.push('Number of channels is required.');
                    }
                } 
            }
        }

        // Analog specific validations
        if (obj.IADConfiguration.IADHandoff == 'Analog' || obj.IADConfiguration.IADHandoff == 'Both') {
            
            // Analog (FXS) Trunk Information
            if (obj.AnalogTrunkInformation.NumberOfAnalogHandoffs == null || obj.AnalogTrunkInformation.NumberOfAnalogHandoffs == '') {
                $scope.modal.msgs.push('Number of Analog Handoffs is required.');
            }
            if (obj.AnalogTrunkInformation.PunchdownInformation == null || obj.AnalogTrunkInformation.PunchdownInformation == '') {
                $scope.modal.msgs.push('Punch-down Information is required.');
            }
            if (obj.AnalogTrunkInformation.AnalogStartDialMethod == null || obj.AnalogTrunkInformation.AnalogStartDialMethod == '') {
                $scope.modal.msgs.push('Start dial method is required.');
            }

            // Analog (FXS) Optional Accessories/Kits
            if (obj.AnalogAccessoriesKits.x66Block == null || obj.AnalogAccessoriesKits.x66Block == '') {
                $scope.modal.msgs.push('66 Block is required.');
            }
            if (obj.AnalogAccessoriesKits.x66BlockBracket == null || obj.AnalogAccessoriesKits.x66BlockBracket == '') {
                $scope.modal.msgs.push('66 Block Bracket is required.');
            }
            if (obj.AnalogAccessoriesKits.x66BlockCover == null || obj.AnalogAccessoriesKits.x66BlockCover == '') {
                $scope.modal.msgs.push('66 Block Cover is required.');
            }
            if (obj.AnalogAccessoriesKits.AmphenolCable == null || obj.AnalogAccessoriesKits.AmphenolCable == '') {
                $scope.modal.msgs.push('Amphenol Cable is required.');
            }

            // Analog Hunting
            if (obj.AnalogHunting.HuntEnabled == null || obj.AnalogHunting.HuntEnabled == '') {
                $scope.modal.msgs.push('Is "Hunt" enabled?');
            } else {
                if (obj.AnalogHunting.HuntEnabled == 'Yes') {
                    if (obj.AnalogHunting.HuntArrangement == null || obj.AnalogHunting.HuntArrangement == '') {
                        $scope.modal.msgs.push('Hunt Arrangement is required.');
                    }
                    if (obj.AnalogHunting.TelephoneNumberHuntSequence == null || obj.AnalogHunting.TelephoneNumberHuntSequence == '') {
                        $scope.modal.msgs.push('Phone Number Hunt Sequence is required.');
                    }

                }
            }
            
        }
        
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


    function hasValidNPANXX(element) {
        let voipQualifications = getElementValue('VOIPQualifications');
        let hasError = true;
        let btn = getElementValue(element);
        if (angular.isArray(voipQualifications)) {
            for (let i=0; i < voipQualifications.length; i++) {
                let currentNPANXX = "" + voipQualifications[i].NPA + voipQualifications[i].NXX;
                if (btn.startsWith(currentNPANXX)) {
                    hasError = false;
                    break;
                }
            }
        } else {
            let currentNPANXX = "" + voipQualifications.NPA + voipQualifications.NXX;
            if (btn.startsWith(currentNPANXX)) hasError = false;
        }
        return hasError;
        
    }

}])