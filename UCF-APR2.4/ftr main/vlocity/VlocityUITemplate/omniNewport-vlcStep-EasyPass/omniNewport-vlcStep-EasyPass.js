vlocity.cardframework.registerModule.controller('EasyPassStepController', ['$scope','$rootScope','bpService','$q', function ($scope,$rootScope,bpService,$q) {

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
                $scope.modal.msgs.push('Speed is required.');
            } 

        } else if (step.name == 'ConfigureYourProduct') {
            let product = getElementValue('CurrentProduct');
            if (product.RAWSpeed > 1000 && product.RAWSpeed <= 10000) {
                if (getElementValue(bpPaths.interfaceType) == 'Copper RJ45' || getElementValue(bpPaths.interfaceType) == 'Electrical - RJ45') {
                    $scope.modal.msgs.push('Electrical - RJ45 does not support more than 1 Gbps.');
                }
            }

            if ($scope.modal.msgs.length == 0) {
                $scope.createQLIs();
                return false;
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

    $scope.getConfiguredOptions = function() { 
        var inputParam = {
            productCode: getElementValue(bpPaths.productCode),
            serviceAccountId: getElementValue(bpPaths.currentLocation+'.Id'),
            term: getElementValue(bpPaths.term)
        };
        if (!inputParam.productCode || !inputParam.serviceAccountId || !inputParam.term) return;
        $rootScope.loading = true;
        var configObj = {
            sClassName: 'PricingFormulaService', sMethodName: 'getAllPricingOptionsByTerm', input: angular.toJson(inputParam),
            options: angular.toJson({}), iTimeout: null, label: null
        };
        return $q(function(resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(
                function (result) {
                    var res = JSON.parse(result);
                    $rootScope.loading = false;
                    $scope.bpTree.response.ConfiguredOptions = [];
                    for (var key in res) {
                        if (res.hasOwnProperty(key)) {
                            if (key =='error') continue;
                            res[key].ServiceAccountName = getElementValue(bpPaths.currentLocation+'.Name');
                            res[key].RAWSpeed = convertSpeedToMB(res[key].Speed__c);
                            $scope.bpTree.response.ConfiguredOptions.push(res[key]);
                        }
                    }
                },
                function (error) {
                    console.error(error);
                    $rootScope.loading = false;
                }
            )
        });
    };

    function convertSpeedToMB(speed) {
        if (speed == null) return 0;
        speed = speed.toUpperCase();

        if (speed.includes('GB')) {
            return parseInt(speed.replace(/\D/g,'')) * 1000;
        } else {
            return parseInt(speed.replace(/\D/g,''));
        }
    }

    function findMsgByCode(msgArray) {
        return msgArray.find(obj => obj.code == '150' || obj.code == '151') !== undefined;
    }

    $scope.createQLIs = function(step) {
        $rootScope.loading = true;
        // 1st create DIA
        var items = [
            {
                "attributesToUpdate": {
                    "ATTR_CONTRACT_TERM": getElementValue('CurrentProduct:Term__c'),
                    "ATTR_BANDWIDTH": getElementValue('CurrentProduct:Speed__c')
                    
                },
                "fieldsToUpdate": {
                    "%vlocity_namespace%__ServiceAccountId__c": getElementValue('CurrentProduct:%vlocity_namespace%__ServiceAccountId__c'),
                    "Quantity": 1,
                    "Speed__c": getElementValue('CurrentProduct:Speed__c')
                },
                "itemId": getElementValue('ProductInfo:PricebookEntryId'),
                "ProductCode": getElementValue('ProductInfo:ProductCode'),
                "isEasyPass": true
            }
        ];
        setElementValue(createItemsVIP.Node, items);
        var configObj = {
            sClassName:bpService.sNSC+'IntegrationProcedureService',
            sMethodName:createItemsVIP.Name,
            input:angular.toJson($scope.bpTree.response),
            options:angular.toJson({})
        };
        return $q(function(resolve, reject){
            bpService.OmniRemoteInvoke(configObj).then(
                function(result)
                {
                    var remoteResp = angular.fromJson(result);
                    console.log(remoteResp);
                    if(remoteResp && remoteResp.IPResult)
                    {
                        var isSuccess = findMsgByCode(remoteResp.IPResult.QuoteLineItem.messages);
                        if (!isSuccess) {
                            console.error(remoteResp.IPResult);
                        } else {
                            // if no errors, set the IP Block on the child product  
                            var record = remoteResp.IPResult.QuoteLineItem.records[0];
                            if (record.lineItems && record.lineItems.records && record.lineItems.records[0]) {
                                var lineItem = record.lineItems.records[0];
                                if (lineItem.attributeCategories && lineItem.attributeCategories.records) {
                                    for (let i=0; i < lineItem.attributeCategories.records.length; i++) {
                                        if (lineItem.attributeCategories.records[i].productAttributes && lineItem.attributeCategories.records[i].productAttributes.records) {
                                            for (let j=0; j < lineItem.attributeCategories.records[i].productAttributes.records.length; j++) {
                                                if (lineItem.attributeCategories.records[i].productAttributes.records[j].code == 'ATTR_IP_BLOCKS') {
                                                    lineItem.attributeCategories.records[i].productAttributes.records[j].userValues = getElementValue(bpPaths.ipBlock);
                                                }
                                                 if (lineItem.attributeCategories.records[i].productAttributes.records[j].code == 'ATTR_CONTRACT_TERM') {
                                                    lineItem.attributeCategories.records[i].productAttributes.records[j].userValues = getElementValue('CurrentProduct:Term__c');
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            var recordObj = {
                                records: [record]
                            };
                            console.log('new record created:', recordObj);
                            var qLIs = getElementValue('QuoteLineItems');
                            
                            qLIs.push(recordObj);
                            setElementValue('QuoteLineItems', qLIs);
                            console.log('total records:', getElementValue('QuoteLineItems'));
                             
                            // update the child product
                            var inputParam = {
                                cartId: getElementValue('QuoteId'),
                                items: recordObj,
                                price: true,
                                validate: false,
                                methodName: 'putCartsItems'
                            };
                            var configObj = {
                                sClassName: 'ftr_CpqService', sMethodName: 'invokeCpqAppHandlerMethod', input: angular.toJson(inputParam),
                                options: angular.toJson({}), iTimeout: null, label: null
                            };
                            
                            bpService.OmniRemoteInvoke(configObj).then(
                               
                                function (result) {
                                    var resp = angular.fromJson(result);
                                    var result;
                                    if (resp && resp.result)
                                        result = JSON.parse(resp.result);
                                    console.log(result);
                                    let product = getElementValue('CurrentProduct');
                                    
                                    
                                    let portSpeed = '1G';
                                     if (product.RAWSpeed > 1000 && product.RAWSpeed <= 10000) {
                                           console.log('So....you selected a 2G');
                                        portSpeed = '10 GBPS';
                                    }
                                    else if (product.RAWSpeed > 10000 && product.RAWSpeed <= 100000){
                                        portSpeed = '100 GBPS';
                                    }
                                    if(result) {
                                        var isSuccess = findMsgByCode(result.messages);
                                        if (isSuccess) {
                                            // add the UNI
                                            var inputParam2 = {
                                                cartId: getElementValue('QuoteId'),
                                                items: [
                                                    {
                                                        fieldsToUpdate: {
                                                            %vlocity_namespace%__ServiceAccountId__c: getElementValue('CurrentProduct:%vlocity_namespace%__ServiceAccountId__c'),
                                                            Quantity: 1,
                                                            Speed__c: getElementValue('CurrentProduct:Speed__c')
                                                        },
                                                        attributesToUpdate: {
                                                            ATTR_PHY_MEDIUM: getElementValue(bpPaths.fiberMode),
                                                            ATTR_CONTRACT_TERM: getElementValue('CurrentProduct:Term__c'),
                                                            ATTR_PORT_SPEED: portSpeed,
                                                           // ATTR_UNI_PORT_SP: portSpeed,
                                                            ATTR_BANDWIDTH: getElementValue('CurrentProduct:Speed__c')
                                                        },
                                                        itemId: getElementValue('UNIInfo:PBEId'),
                                                        ProductCode: getElementValue('UNIProductCode')
                                                    }
                                                ],
                                                price: false,
                                                validate: false,
                                                methodName: 'postCartsItems'
                                            };
                                            var configObj2 = {
                                                sClassName: 'ftr_CpqService', sMethodName: 'invokeCpqAppHandlerMethod', input: angular.toJson(inputParam2),
                                                options: angular.toJson({}), iTimeout: null, label: null
                                            };
                                            bpService.OmniRemoteInvoke(configObj2).then(
                                                function (result) {
                                                    var res = JSON.parse(result);
                                                    $rootScope.loading = false;
                                                    $scope.bpTree.response.StepLoopCount++;
                                                    var stepLoopCount = getElementValue('StepLoopCount');
                                                    var numOfLocs = getElementValue('selectedLocations').length;
                                                    if (numOfLocs > 1 && stepLoopCount != numOfLocs) {
                                                        setElementValue('FreezeTerm', true);
                                                        setElementValue(bpPaths.currentLocation, getElementValue('selectedLocations')[stepLoopCount]);
                                                        gotoStep('BuildYourProduct');
                                                        $scope.getConfiguredOptions();
                                                    } else {
                                                        $scope.nextRepeater($scope.child.nextIndex, $scope.child.indexInParent);
                                                    }
                                                    
                                                },
                                                function (error) {
                                                    console.error(error);
                                                    $rootScope.loading = false;
                                                }
                                            );
                                        } else {
                                            console.error(result);
                                        }
                                    } 
                                },
                                function (error) {
                                    console.error(error);
                                    $rootScope.loading = false;
                                }
                            );
                        }
                    }
                },
                function(error)
                {
                    console.error(error);
                    $rootScope.loading = false;
                }
            );
        });
    };

    $scope.$watch('bpTree.response.'+bpPaths.term, function(newVal, oldVal) {
        if (newVal != oldVal) {
            $scope.getConfiguredOptions();
        }
    });

}])