vlocity.cardframework.registerModule.controller('SelectableItemFTRLabelChanged', ['$scope', '$rootScope', 'bpService', function ($scope, $rootScope, bpService) {
    const productsWithoutTerm = [];
    
    var customLoading = false;
    
    //Licenes Product Codes
    const RC_BASIC_SEAT = 'RC_BASIC_SEAT',
        RC_STANDARD_SEAT = 'RC_STANDARD_SEAT',
        RC_ESSENTIAL_SEAT = 'RC_ESSENTIAL_SEAT',
        RC_PREMIUM_SEAT = 'RC_PREMIUM_SEAT',
        RC_LIMITED_EXTENSION = 'RC_LIMITED_EXTENSION';

    //AddOn Product Codes
    const RC_ADD_ON_SERVICES_BASIC = 'RC_ADD_ON_SERVICES_BASIC';
    const RC_ADD_ON_SERVICES_ESSENTIAL = 'RC_ADD_ON_SERVICES_ESSENTIAL';
    const RC_ADD_ON_SERVICES_STANDARD = 'RC_ADD_ON_SERVICES_STANDARD';
    const RC_ADD_ON_SERVICES_PREMIUM = 'RC_ADD_ON_SERVICES_PREMIUM';
    
    const RC_ADD_ON_SERVICES_LIST = [
        RC_ADD_ON_SERVICES_BASIC,
        RC_ADD_ON_SERVICES_ESSENTIAL,
        RC_ADD_ON_SERVICES_STANDARD,
        RC_ADD_ON_SERVICES_PREMIUM
    ];

    const RC_RCV_LARGE_MEET_200 = 'RC_RCV_LARGE_MEET_200';
    const RC_RCV_LARGE_MEET_200_PR = 'RC_RCV_LARGE_MEET_200_PR';
    const RC_RINGCENTRAL_ROOMS = 'RC_RINGCENTRAL_ROOMS';
    const RC_PUSH_TO_TALK = 'RC_PUSH_TO_TALK';
    const RC_LIVE_REPORTS = 'RC_LIVE_REPORTS';
    
    const CONDITIONED_ADD_ONS = [
        RC_RCV_LARGE_MEET_200,
        RC_RINGCENTRAL_ROOMS,
        RC_PUSH_TO_TALK,
        RC_LIVE_REPORTS
    ];

    $scope.showAddonIncludedMsg = false;
    $scope.rootRecord = {};
    $scope.productList = [];
    $scope.spinnerLoading = false;

    $scope.$watch('control.vlcSI[control.itemsKey][0]', function (newValue, oldValue) {
        if(newValue != oldValue) {
            $scope.setListOfRecords();
        }
    });

    $scope.setListOfRecords = function () {
        if ($scope.control.propSetMap.isAddonsPage) { 
            var arr1 = [];
            var arr2 = [];
            for (var i = 0; i < $scope.control.vlcSI[$scope.control.itemsKey][0].records.length; i++) {
                if (RC_ADD_ON_SERVICES_LIST.indexOf($scope.control.vlcSI[$scope.control.itemsKey][0].records[i].ProductCode) != -1) {
                    
                    $scope.bpTree.response.productsListAddedToCart.push(
                        {
                            "childRecords": [],
                            "Quantity": {
                                "value": 1
                            },
                            "Product2": {
                                "%vlocity_namespace%__Type__c": $scope.control.vlcSI[$scope.control.itemsKey][0].records[i].Product2.%vlocity_namespace%__Type__c
                            },
                            "ProductCode": $scope.control.vlcSI[$scope.control.itemsKey][0].records[i].ProductCode
                        }
                    );

                    $scope.bpTree.response.AddonNodeToDelete = {
                        actions: {
                            deleteitem: {
                                remote: $scope.control.vlcSI[$scope.control.itemsKey][0].records[i].actions.deleteitem.remote
                            }
                        }
                    };

                    arr1 = $scope.control.vlcSI[$scope.control.itemsKey][0].records[i].childProducts.records;
                    if ($scope.control.vlcSI[$scope.control.itemsKey][0].records[i].lineItems) {
                        arr2 = $scope.control.vlcSI[$scope.control.itemsKey][0].records[i].lineItems.records;    
                    }
                    $scope.productList = mergeArrayAndOrderedByField(arr1, arr2, 'sequenceNumber');
                    break;
                }
            }
        } else {
            $scope.bpTree.response.productsListAddedToCart = [];
            $scope.productList = orderArrayByField($scope.control.vlcSI[$scope.control.itemsKey][0].records, true, '%vlocity_namespace%__RecurringPrice__c', 'value');
            
            var configObj = {
                sClassName: '%vlocity_namespace%.IntegrationProcedureService',
                sMethodName: 'RingCentral_GetItemsFromCart',
                input: angular.toJson({ cartId: $scope.bpTree.response.ContextId }),
                options: angular.toJson({})
            };
            $scope.spinnerLoading = true;
            bpService.OmniRemoteInvoke(configObj).then(function (result) {

                var resultParsed = JSON.parse(result).IPResult;
                $scope.bpTree.response.productsListAddedToCart = resultParsed.productsListAddedToCart || [];
                if ($scope.bpTree.response.productsListAddedToCart) {
                    for (var j = 0; j < $scope.bpTree.response.productsListAddedToCart.length; j++) {
                        if ($scope.bpTree.response.productsListAddedToCart[j].Product2.%vlocity_namespace%__Type__c == 'License') {
                            setAddonServiceCodeToAddBasedOnLicense($scope.bpTree.response.productsListAddedToCart[j].ProductCode);
                            break;
                        }
                    }
                }

                $scope.spinnerLoading = false;
            }).catch(function (error) {
                console.error('Error while calling IP ', error);
                alert(JSON.stringify(error));
                $scope.spinnerLoading = false;
                reject(error);
            });
        }
    }

    $scope.nsPrefix = '%vlocity_namespace%__';

    $scope.addProduct = function(product, control, ele) {
        if(checkProductAdded(product.ProductCode.value) ||  $scope.spinnerLoading) {
            return;
        }
        
        if ($scope.control.propSetMap.isAddonsPage) { 
            for (var j = 0; j < $scope.control.vlcSI[$scope.control.itemsKey][0].records.length; j++) {
                if (RC_ADD_ON_SERVICES_LIST.indexOf($scope.control.vlcSI[$scope.control.itemsKey][0].records[j].ProductCode) != -1) {
                    $scope.rootRecord = $scope.control.vlcSI[$scope.control.itemsKey][0].records[j];
                }
            }
        } else {
            for (var i = 0; i < $scope.bpTree.response.productsListAddedToCart.length; i++) {
                if (RC_ADD_ON_SERVICES_LIST.indexOf($scope.bpTree.response.productsListAddedToCart[i].ProductCode) != -1) {
                    $scope.bpTree.response.productsListAddedToCart.splice(i,1);
                    break;
                }
            }
        }

        setAddonServiceCodeToAddBasedOnLicense(product.ProductCode.value);
        
        // set fields for parent and child products
        for (let i=0; i < product.actions.addtocart.remote.params.items.length; i++) {
            var productCode = product.ProductCode.value;
            
            // field to update for all products getting added
            product.actions.addtocart.remote.params.items[i].fieldsToUpdate = {
                '%vlocity_namespace%__ServiceAccountId__c' : $scope.bpTree.response.SelectServiceLocation.CurrentLocationId
            };

            // set term for those not in list
            if (!productsWithoutTerm.includes(productCode)) {
                // field
                product.actions.addtocart.remote.params.items[i].fieldsToUpdate.Term__c = $scope.bpTree.response.SelectServiceLocation.ServiceTerm
                // attribute
                product.actions.addtocart.remote.params.items[i].attributesToUpdate = {
                    'ATTR_CONTRACT_TERM' : $scope.bpTree.response.SelectServiceLocation.ServiceTerm
                };
            }
            
            // pass fields for apex putCartItems.PreInvoke
            product.actions.addtocart.remote.params.items[i].ProductCode = productCode;
        }
        
        makeTheCall(product, control, $scope.rootRecord);
        
    }

    function makeTheCall(product, control, rootProduct) {
        var currentItem;
        var className = control.propSetMap.remoteClass,
        methodName = control.propSetMap.remoteMethod,
        opt = control.propSetMap.remoteOptions,
        timeout = control.propSetMap.remoteTimeout,
        inputParam = Object.keys(product.actions.addtocart.remote.params).length > 0 ? product.actions.addtocart.remote.params : (Object.keys(product.actions.addtocart.rest.params).length > 0 ? product.actions.addtocart.rest.params : null);

        
        if (!angular.equals(rootProduct, {})) {
            delete rootProduct.childProducts;
            delete rootProduct.actions;
            delete rootProduct.messages;

            inputParam.items[0].parentRecord = {
                records: [
                    rootProduct
                ]
            };
        }
        
        var configObj = {
            sClassName: className, 
            sMethodName: methodName, 
            input: angular.toJson(inputParam),
            options: angular.toJson(opt), 
            iTimeout: timeout, 
            label: { label: control && control.name }
        };

        $rootScope.loading = true;
        bpService.OmniRemoteInvoke(configObj).then(
            function (result) {
                if ($scope.control.propSetMap.isAddonsPage) { 
                    for (var i = 0; i < $scope.bpTree.response.productsListAddedToCart.length; i++) {
                        if ($scope.bpTree.response.productsListAddedToCart[i].ProductCode == $scope.bpTree.response.AddonProductCodeToAdd) {
                            $scope.bpTree.response.productsListAddedToCart[i].childRecords = $scope.bpTree.response.productsListAddedToCart[i].childRecords ? $scope.bpTree.response.productsListAddedToCart[i].childRecords : [];
                            $scope.bpTree.response.productsListAddedToCart[i].childRecords.push({
                                action: "Add",
                                ProductCode: product.ProductCode.value
                            });
                            break;
                        }
                    }
                } else {
                    $scope.bpTree.response.productsListAddedToCart.push({
                        Product2: {
                            %vlocity_namespace%__Type__c: product.Product2.%vlocity_namespace%__Type__c
                        },
                        Quantity: {
                            value: 1
                        },
                        ProductCode: product.ProductCode.value
                    });
                }

                var configObject = {
                    sClassName: 'ftr_RingCentralUtils', 
                    sMethodName: 'updateServiceAccountField', 
                    input: angular.toJson({ ServiceAccountId: $scope.bpTree.response.SelectServiceLocation.CurrentLocationId, cartId: $scope.bpTree.response.ContextId}),
                    options: angular.toJson(opt), 
                    iTimeout: timeout, 
                    label: { label: control && control.name }
                }
                bpService.OmniRemoteInvoke(configObject).then(
                    function (result) {
                        var configObjCartLines = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCarts', 
                            input: angular.toJson({ cartId: $scope.bpTree.response.ContextId, price: true, validate: true, methodName: "getCarts" }),
                            options: angular.toJson(opt), 
                            iTimeout: timeout, 
                            label: { label: (control && control.name) }
                        };
                        bpService.OmniRemoteInvoke(configObjCartLines).then(
                            function (result) {
                                var resp = angular.fromJson(result);

                                $scope.bpTree.response.vlcPersistentComponent['vlcCart_Top'] = [resp];
                                
                                var configObjCart = {
                                    sClassName: '%vlocity_namespace%.CpqAppHandler', 
                                    sMethodName: 'getCartsItems', 
                                    input: angular.toJson({ pagesize: 10, price:false, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                                    options: angular.toJson(opt), 
                                    iTimeout: timeout, 
                                    label: { label: (control && control.name) }
                                };
                                bpService.OmniRemoteInvoke(configObjCart).then(
                                    function (result) {
                                        var resp = angular.fromJson(result);
                                        $scope.bpTree.response.vlcPersistentComponent['vlcCart'] = resp;
                                        $rootScope.loading = false;
                                    },
                                    function (error) {
                                        console.error(error);
                                    }
                                );
                            },
                            function (error) {
                                console.error(error);
                            }
                        );
                        
                    },
                    function (error) {
                        console.error(error);
                    }
                );
                var resp = angular.fromJson(result);
                resp = JSON.parse(resp.result);

                var hasError = false, errorMsg = '';
                angular.forEach(resp.messages, function (message) {
                    if (message.severity === 'ERROR') {
                        hasError = true;
                        errorMsg = message.message;
                    }
                });

                if (hasError && !resp.records) {
                    console.error(errorMsg);
                    return;
                }

                for (var i = 0; i < resp.records.length; i++) {
                    if ($scope.bpTree.response.vlcPersistentComponent['vlcCart'].records)
                        $scope.bpTree.response.vlcPersistentComponent['vlcCart'].records.unshift(resp.records[i]);
                    else
                        $scope.bpTree.response.vlcPersistentComponent['vlcCart'].records = resp.records;
                }    
            },
            function (error) {
                console.error(error);
            }
        );
    }

    $scope.formatJson = function(string) {
        return string ? JSON.parse(string) : {};
    }

    function setAddonServiceCodeToAddBasedOnLicense(licenseCode) {
        switch(licenseCode) {
            case RC_BASIC_SEAT: 
                $scope.bpTree.response.AddonProductCodeToAdd = 'RC_ADD_ON_SERVICES_BASIC';
                break;
            case RC_ESSENTIAL_SEAT:
                $scope.bpTree.response.AddonProductCodeToAdd = 'RC_ADD_ON_SERVICES_ESSENTIAL';
                break;
            case RC_STANDARD_SEAT: 
                $scope.bpTree.response.AddonProductCodeToAdd = 'RC_ADD_ON_SERVICES_STANDARD';
                break;
            case RC_PREMIUM_SEAT: 
                $scope.bpTree.response.AddonProductCodeToAdd = 'RC_ADD_ON_SERVICES_PREMIUM';
                break;
        }
    }

    $scope.setSelectedDisabledClass = function(product) {
        if ($scope.control.propSetMap.isAddonsPage) { 
            if ((product.ProductCode.value == RC_RCV_LARGE_MEET_200_PR || product.ProductCode == RC_RCV_LARGE_MEET_200_PR) && checkProductAdded(RC_PREMIUM_SEAT)) {
                $scope.showAddonIncludedMsg = true;
                return 'disabled';
            } else {
                $scope.showAddonIncludedMsg = false;
            }
            
            if ((checkProductAdded(RC_ESSENTIAL_SEAT) || checkProductAdded(RC_BASIC_SEAT)) && CONDITIONED_ADD_ONS.indexOf(product.ProductCode.value) != -1) {
                return 'disabled';
            } else if (checkProductAdded(product.ProductCode.value)) {
                return 'selected';
            } else {
                return '';
            }

        } else {
            if (checkIfLicenseAdded() || checkProductAdded(RC_LIMITED_EXTENSION)) {
                if (checkProductAdded(product.ProductCode.value)) {
                    return 'selected';

                } else if (!checkProductAdded(product.ProductCode.value)) {
                    if (product.ProductCode.value == RC_LIMITED_EXTENSION && (checkProductAdded(RC_PREMIUM_SEAT) || checkProductAdded(RC_STANDARD_SEAT))) {
                        return '';
                    }
                    if ((product.ProductCode.value == RC_PREMIUM_SEAT || product.ProductCode.value == RC_STANDARD_SEAT) && checkProductAdded(RC_LIMITED_EXTENSION) && !checkIfLicenseAdded()) {
                        return '';
                    }
                    return 'disabled';
                }
            } else {
                return '';
            }
        }   
    }

    function checkProductAdded(productCode) {
        if ($scope.bpTree.response.productsListAddedToCart) {
            var productsAddedToTheCart = $scope.bpTree.response.productsListAddedToCart;
            for (i = 0; i < productsAddedToTheCart.length; i++) {
                if (RC_ADD_ON_SERVICES_LIST.indexOf(productsAddedToTheCart[i].ProductCode) != -1 && productsAddedToTheCart[i].childRecords) {
                    for (j = 0; j < productsAddedToTheCart[i].childRecords.length; j++) {
                        if (productsAddedToTheCart[i].childRecords[j].ProductCode == productCode && productsAddedToTheCart[i].childRecords[j].action == 'Add') {
                            return true;
                        }
                    }
                } else if (productsAddedToTheCart[i].ProductCode == productCode) {
                    return true;
                }
            }
        }
        return false;
    }

    function checkIfLicenseAdded() {
        if ($scope.bpTree.response.productsListAddedToCart) {
            var productsAddedToTheCart = $scope.bpTree.response.productsListAddedToCart;
            for (i = 0; i < productsAddedToTheCart.length; i++) {
                // if(productsAddedToTheCart[i].Product2 && (productsAddedToTheCart[i].Product2.%vlocity_namespace%__Type__c == 'License' || productsAddedToTheCart[i].Product2.%vlocity_namespace%__Type__c == 'License Add-on')) {
                if(productsAddedToTheCart[i].Product2 && (productsAddedToTheCart[i].Product2.%vlocity_namespace%__Type__c == 'License')) {
                    return true;
                }
            }
            return false;
        }
    }

    function mergeArrayAndOrderedByField(arr1, arr2, orderByField) {
        var mergedArray = arr1;
        var exist = false;
        for (i=0; i < arr2.length; i++) {
            for(j=0; j < arr1.length; j++) {
                if(arr2[i].ProductCode == arr1[j].ProductCode.value) {
                    exist = true;
                    break
                }
            }
            if(!exist) {
                mergedArray.push(arr2[i]);
            }
        }
        mergedArray = orderArrayByField(mergedArray, false, orderByField);

        return mergedArray;
    }

    function orderArrayByField(list, parseToNumber, ...path) {
        return list.sort((a, b) => getFromPath(a, parseToNumber, path) - getFromPath(b, parseToNumber, path));
    }

    function getFromPath(obj, parseToNumber, path) {
        let r = obj;
        path.forEach(key => { r = r[key]});
        return parseToNumber ? parseFloat(r.split('$')[1]) : r;
    }

}])