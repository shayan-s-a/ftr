vlocity.cardframework.registerModule.controller('EasyPassStepController', ['$scope','$timeout','$rootScope','bpService','$q', function ($scope,$timeout,$rootScope,bpService,$q) {

    const createItemsVIP = {
        Name: 'Create_QLIs',
        Node: 'itemToCreate'
    };

    const bpPaths = {
        term: 'BuildYourProduct.Term',
        currentLocation: 'CurrentLocation',
        productCode: 'ProductCode',
        numOfLocations: 'LocationCount',
        fiberMode: 'ConfigureYourProduct.ConfigurationQuestions.InterfaceType',
        ipBlock: 'ConfigureYourProduct.ConfigurationQuestions.IPAddressBlock',
        interfaceType: 'ConfigureYourProduct.ConfigurationQuestions.InterfaceType'
    };

    $scope.hideModal = function () {
       $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
       $scope.modal.showModal = true;
    }

    $scope.goNext = function (step) {
        if(stepIsValid(step)) {
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
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

    function stepIsValid (step) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };

        if (step.name == 'DisplayServiceLocations') {

            if (!getElementValue('selectedLocations') || !getElementValue('selectedLocations')[0]) {
                $scope.modal.msgs.push('Service location is required.');
            } else if (getElementValue('selectedLocations').length > 0) {
                for (let i=0; i < getElementValue('selectedLocations').length; i++) {
                    let location = getElementValue('selectedLocations')[i];
                    if (location.Premises == null) {
                        $scope.modal.msgs.push(location.ShippingStreet + ' requires a DSAT refresh.');
                    } 
                }
            }

            if ($scope.modal.msgs.length == 0) {
                setElementValue(bpPaths.currentLocation, getElementValue('selectedLocations')[0]);
            }

        } else if (step.name == 'BuildYourProduct') {
            console.log(getElementValue('CurrentProduct'));
            if (getElementValue(bpPaths.term) == null) {
                $scope.modal.msgs.push('Term is required.');
            } else if (Object.keys(getElementValue('CurrentProduct')).length === 0) {
                $scope.modal.msgs.push('A Bundle is required.');
            } 

        } else if (step.name == 'ConfigureYourProduct') {
            if ($scope.modal.msgs.length == 0) {
                // grab the omniscript data
                let osData = getElementValue('OSData');
                let currentProduct = getElementValue('CurrentProduct');
                if (currentProduct.BundlePrice.charAt(0) == '$') {
                    currentProduct.BundlePrice = currentProduct.BundlePrice.substring(1);
                }
                if (!Array.isArray(osData)) {
                    osData = [osData];
                }
                // check if it's already in there, 1 per service account
                let idx = -1;
                for (let i=0; i<osData.length;i++) {
                    if (osData[i].ServiceAccountId == getElementValue(bpPaths.currentLocation).Id) {
                        idx = i;
                    }
                }
                // remove from the list if its already in there
                if (idx != -1)
                    osData.splice(idx, 1);

                // add to the list and set the data
                osData.push(currentProduct);
                setElementValue('OSData', osData);

                // loop thru the next location
                $scope.bpTree.response.StepLoopCount++;
                var stepLoopCount = getElementValue('StepLoopCount');
                var numOfLocs = getElementValue('selectedLocations').length;
                if (numOfLocs > 1 && stepLoopCount != numOfLocs) {
                    setElementValue('FreezeTerm', true);
                    // $scope.bpTree.response.FreezeTerm = true;
                    setElementValue(bpPaths.currentLocation, getElementValue('selectedLocations')[stepLoopCount]);
                    // gotoStep('BuildYourProduct');
                    gotoStep('GetProductsBundlesintialize');
                    
                } else {
                    setElementValue('Finished', true);
                    //$scope.nextRepeater($scope.child.nextIndex, $scope.child.indexInParent);
                }
            }
           
        }

        if ($scope.modal.msgs.length > 0) {
            $scope.showModal();
            return false;
        }
        
        return true;
    }

    function getFieldErrors(step) {
        var errors = [];
        // wont work for repeatable block
        for (let i = 0; i < step.children.length; i++) {
            if (step.children[i].eleArray[0].propSetMap.required && (step.children[i].response == null || step.children[i].response == ''))  {
                if (step.children[i].eleArray[0].propSetMap.label.includes('?'))
                    errors.push(step.children[i].eleArray[0].propSetMap.label)
                else
                    errors.push(step.children[i].eleArray[0].propSetMap.label + ' is required.')
            }
        }
        return errors;
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

    

    function convertSpeedToMB(speed) {
        if (speed == null) return 0;
        speed = speed.toUpperCase();

        if (speed.includes('GB')) {
            return parseInt(speed.replace(/\D/g,'')) * 1000;
        } else {
            return parseInt(speed.replace(/\D/g,''));
        }
    }

   
    $scope.$watch('bpTree.response.BuildYourProduct.BundleType', function(newVal, oldVal) {
        if (newVal != oldVal) {
            $timeout(function() {
                console.log('inside');
                setElementValue('ConfiguredOptions',null);
                $('#GetProductsBundles').click();  
             }, 0);
        }
    });

     $scope.$watch('bpTree.response.BuildYourProduct.Term', function(newVal, oldVal) {
        if (newVal != oldVal) {
            $timeout(function() {
                console.log('inside');
                setElementValue('ConfiguredOptions',null);
                $('#GetProductsBundles').click();  
             }, 0);
        }
    });

   
}])