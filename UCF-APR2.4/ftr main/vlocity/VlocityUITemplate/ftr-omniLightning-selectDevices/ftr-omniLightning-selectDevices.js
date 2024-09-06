vlocity.cardframework.registerModule.controller('SelectableItemFTRRCDevices', ['$scope', '$rootScope', 'bpService', '$timeout', function ($scope, $rootScope, bpService, $timeout) {

    var control = $scope.control;
    var orderMapList = {
        PR_YEALNK_PHONES: 1,
        PR_POLY_PHONES: 2,
        PR_CISCO_PHONES: 3,
        PR_CONFERENCE_PHONES: 4,
        PR_ATAS_PHONES: 5
    }
    
    $scope.listOfProducts = [];
    $scope.licensesQty = 0;
    $scope.devicesQty = 0;
    $scope.accordionSection = '';
    $scope.showMessage = false;

    $scope.init = init();
    $scope.formatJson = formatJson;
    $scope.addProduct = addProduct;
    $scope.openAccordion = openAccordion;

    function init() {
        $scope.listOfProducts = $scope.control.vlcSI[$scope.control.itemsKey][0].records.sort(function(a, b) {return orderMapList[a.ProductCode.value] - orderMapList[b.ProductCode.value]});
    }

    function formatJson(string) {
        return string ? JSON.parse(string) : {};
    }

    function addProduct (product) {
        console.info('Product: ', product);
        getQuantities();
        if ($scope.devicesQty < $scope.licensesQty) {
            makeTheCall(product, control);
        } else {
            $scope.showMessage = true;
            $timeout(function(){
                $scope.showMessage = false;
            }, 3000);  
        }

    }

    function makeTheCall(product, control) {
        var className = control.propSetMap.remoteClass,
            methodName = control.propSetMap.remoteMethod,
            opt = control.propSetMap.remoteOptions,
            timeout = control.propSetMap.remoteTimeout,
            inputParam = {
                cartId: $scope.bpTree.response.ContextId,
                items: [
                    {
                        itemId: product.Id.value,
                        fieldsToUpdate: {
                            '%vlocity_namespace%__ServiceAccountId__c' : $scope.bpTree.response.SelectServiceLocation.CurrentLocationId
                        }
                    }
                ],
                methodName: "postCartsItems"

            };

        var configObj = {
            sClassName: className, 
            sMethodName: methodName, 
            input: angular.toJson(inputParam),
            options: angular.toJson(opt), 
            iTimeout: timeout, 
            label: { label: control && control.name }
        };
        $rootScope.loading = true;
        bpService
            .OmniRemoteInvoke(configObj)
            .then(
                function (result) {

                    $scope.bpTree.response.productsListAddedToCart.push({
                        Product2: {
                            %vlocity_namespace%__Type__c: product.Product2.%vlocity_namespace%__Type__c
                        },
                        Quantity: {
                            value: 1
                        },
                        ProductCode: product.ProductCode.value
                    });
                    
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
    
    function checkProductAdded(productCode) {
        for (i = 0; i < $scope.bpTree.response.vlcPersistentComponent.vlcCart.records.length; i++) {
            if($scope.bpTree.response.vlcPersistentComponent.vlcCart.records[i].ProductCode == productCode) {
                return true;
            };
        }
        return false;
    }

    function getQuantities() {
        $scope.licensesQty = 0;
        $scope.devicesQty = 0;
        for (i = 0; i < $scope.bpTree.response.productsListAddedToCart.length; i++) {
            if ($scope.bpTree.response.productsListAddedToCart[i].Product2.%vlocity_namespace%__Type__c == 'License Add-on' || $scope.bpTree.response.productsListAddedToCart[i].Product2.%vlocity_namespace%__Type__c == 'License') {
                $scope.licensesQty += $scope.bpTree.response.productsListAddedToCart[i].Quantity.value;
            } else if ($scope.bpTree.response.productsListAddedToCart[i].Product2.%vlocity_namespace%__Type__c == 'Phones') {
                $scope.devicesQty += $scope.bpTree.response.productsListAddedToCart[i].Quantity.value;
            }
        }
    }

    function openAccordion(productCode) {
        if($scope.accordionSection == productCode) {
            $scope.accordionSection = '';
        } else {
            $scope.accordionSection = productCode;
        }
    }
}])