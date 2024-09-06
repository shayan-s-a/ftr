vlocity.cardframework.registerModule.controller('SelectableItemFTRLabelChanged', ['$scope', '$rootScope', 'bpService', function ($scope, $rootScope, bpService) {
    const productsWithoutTerm = [
        'UCF_8P_POE',
        'UCF_24P_POE'
    ];

    $scope.addProduct = function(product, control, ele) {
        console.log('adding', product);
        // set fields for parent and child products
        for (let i=0; i < product.actions.addtocart.remote.params.items.length; i++) {
            var productCode = product.ProductCode.value;
            let multiLoc = $scope.bpTree.response.SelectServiceLocation.CountOfLocations > 1 ? 'YES' : 'NO';
            
            // field to update for all products getting added
            product.actions.addtocart.remote.params.items[i].fieldsToUpdate = {
                '%vlocity_namespace%__ServiceAccountId__c' : $scope.bpTree.response.SelectServiceLocation.CurrentLocationId
            };

            // set term for those not in list
            if (!productsWithoutTerm.includes(productCode)) {
                // field
                product.actions.addtocart.remote.params.items[i].fieldsToUpdate.Term__c = $scope.bpTree.response.ServiceTerm
                // attribute
                product.actions.addtocart.remote.params.items[i].attributesToUpdate = {
                    'ATTR_CONTRACT_TERM' : $scope.bpTree.response.ServiceTerm,
                    'ATTR_MULTILOCATION' : multiLoc
                };
            } else {
                product.actions.addtocart.remote.params.items[i].attributesToUpdate = {
                    'ATTR_MULTILOCATION' : multiLoc
                };
            }
            
            // pass fields for apex putCartItems.PreInvoke
            product.actions.addtocart.remote.params.items[i].ProductCode = productCode;
        }
        makeTheCall(product, control);
    }

    function makeTheCall(product, control) {
        var currentItem;
        var className = control.propSetMap.remoteClass,
        methodName = control.propSetMap.remoteMethod,
        opt = control.propSetMap.remoteOptions,
        timeout = control.propSetMap.remoteTimeout,
        inputParam = Object.keys(product.actions.addtocart.remote.params).length > 0 ? product.actions.addtocart.remote.params : (Object.keys(product.actions.addtocart.rest.params).length > 0 ? product.actions.addtocart.rest.params : null);

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
                        $rootScope.loading = false;
                        var resp = angular.fromJson(result);
                        $scope.bpTree.response.vlcPersistentComponent['vlcCart_Top'] = [resp];
                        
                        var configObjCart = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCartsItems', 
                            input: angular.toJson({ price:false, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                            options: angular.toJson(opt), 
                            iTimeout: timeout, 
                            label: { label: (control && control.name) }
                        };
                        bpService.OmniRemoteInvoke(configObjCart).then(
                            function (result) {
                                $rootScope.loading = false;
                                var resp = angular.fromJson(result);
                                $scope.bpTree.response.vlcPersistentComponent['vlcCart'] = resp;
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

}])