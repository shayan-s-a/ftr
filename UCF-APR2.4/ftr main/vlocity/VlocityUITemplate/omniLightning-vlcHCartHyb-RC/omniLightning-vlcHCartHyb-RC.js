vlocity.cardframework.registerModule.controller("vlcCartCustomControllerRc", function ($scope, $rootScope, $window, $sldsModal, $timeout, $compile, $templateCache, bpService) {

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


    $scope.configAttributeObj = null;
    $scope.reRenderAttributesForm = false;

    $scope.lineItemsQty = 0;
    $scope.childItemsQty = 0;

    $rootScope.vlocity.userCurrency = $scope.bpTree.userCurrencyCode;
    var queue = [], isConfigInProcess = false, vlcHCartHybStr;

    if ('parentIFrame' in window) {
        parentIFrame.setHeightCalculationMethod('documentElementOffset');
        vlcHCartHybStr = $templateCache.get('vlcHCartHyb.html');
        if (vlcHCartHybStr.indexOf('vlc-slds-cart-container__parentIFrame') === -1) {
            vlcHCartHybStr = vlcHCartHybStr.replace('vlc-slds-cart-container', 'vlc-slds-cart-container vlc-slds-cart-container__parentIFrame');
            $templateCache.put('vlcHCartHyb.html', vlcHCartHybStr);
            $compile($templateCache);
        }
    }

    $scope.calculateItemsCount = function () {
        var itemQty = 0;
        var childItemsQty = 0;
        if(!$scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex]].records) {
            childItemsQty = 0;
            return 0;
        }

        angular.forEach($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex]].records, function (item) {
            if (item.Product2 && item.Product2.%vlocity_namespace%__Type__c != 'None' && item.Product2.%vlocity_namespace%__SubType__c != 'None') {
                itemQty++;
            } else {
                if (item.lineItems && item.lineItems.records) {
                    angular.forEach(item.lineItems.records, function (child) {
                        childItemsQty++;
                    });
                }
            }
        });

        return itemQty + childItemsQty;
    }

    $scope.initParent = function (scp, prod) {
        scp[scp.gParentId + '_' + scp.prodHierLevel] = prod;
        var childArray = [];

        if (prod.lineItems && prod.lineItems.records) {
            angular.forEach(prod.lineItems.records, function (value) {
                childArray.push(value);
            });
        }

        if (prod.childProducts && prod.childProducts.records) {
            angular.forEach(prod.childProducts.records, function (childProd) {
                // This checkIfAddonIsNotInCart(...) check is ONLY for optional products (minQuantity=0) with defaultQuantity=0,
                // because these optionals ALWAYS have ONE Addon product in childProducts json structure, even when they have
                // been added to cart, so we do not want to display the childProducts Addon when it has been added to cart as lineItem
                if ($scope.checkIfAddonIsNotInCart(prod, childProd)) {
                    childArray.push(childProd);
                }
            });
        }

        if (prod.productGroups && prod.productGroups.records) {
            angular.forEach(prod.productGroups.records, function (value) {
                childArray.push(value);
            });
        }

        prod.childRecords = childArray;

    }

    $scope.checkIfAddonIsNotInCart = function (parent, addonChildProduct) {
        var parentCardinalityMap;
        var isParentCardinalityMapEmpty;
        var addonCountInParentCardinalityMap;
        parentCardinalityMap = parent[$scope.nsPrefix + 'InCartQuantityMap__c'];
        // if parent cardinality map does EXIST and NOT EMPTY and addon child product has a count in the map
        if (parentCardinalityMap && parentCardinalityMap.value && !_.isEmpty(parentCardinalityMap.value) &&
            addonChildProduct.Product2 && addonChildProduct.Product2.Id && parentCardinalityMap.value[addonChildProduct.Product2.Id]) {
            return false; // the child product must have been added to cart
            // otherwise
        } else {
            return true; // the child product has not been added to the cart
        }
    };

    //######### Cardinality Section Start ########

    $scope.checkCardinalityForAdd = function (parent, lineItemChildProduct) {
        var product2Id = lineItemChildProduct.PricebookEntry.Product2.Id;
        // addToCart lineItem will be added with default quantity, except when it is 0.  In the latter case, we will add quantity of 1.
        var additionalQuantity = (lineItemChildProduct.defaultQuantity > 0) ? lineItemChildProduct.defaultQuantity : 1;
        return checkCardinalityForAddOrClone(parent, lineItemChildProduct, product2Id, additionalQuantity);
    };

    $scope.checkCardinalityForClone = function (parent, lineItemChildProduct) {
        var product2Id = lineItemChildProduct.PricebookEntry.Product2.Id;
        // clone lineItem will be added with the quantity of the lineItem, except when user typed a 0 which we forbid.
        // In the latter case, we will forbid user from cloning the lineItem.
        var additionalQuantity = lineItemChildProduct.Quantity.value;
        return (additionalQuantity > 0) ? checkCardinalityForAddOrClone(parent, lineItemChildProduct, product2Id, additionalQuantity) : false;
    };

    $scope.handleRemoteCallError = function (element, errorMsg, bBtn, bApply, operation, callback) {
        if (errorMsg) {
            if (errorMsg.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                errorMsg = errorMsg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
            }
            $scope.toast = {
                status: 'error',
                show: true,
                message: errorMsg
            };
            $timeout(function() {
                $scope.toast = {};
            }, 5000);
        }
    }

    $scope.checkCardinalityForAddon = function (parent, addonChildProduct) {
        var product2Id = addonChildProduct.Product2.Id;

        // addToCart Addon will be added with default quantity, except when it is 0.  In the latter case, we will add quantity of 1.
        var additionalQuantity = (addonChildProduct.defaultQuantity > 0) ? addonChildProduct.defaultQuantity : 1;

        var groupCardinalityCheckPassed;

        if (parent[$scope.nsPrefix + 'InCartQuantityMap__c'] && parent[$scope.nsPrefix + 'InCartQuantityMap__c'].value) {

            // Even though this is Addon with an "Add to Cart" button, but we still need to check for both PCI besides Group
            // cardinality because the first time when user clicks on the "Add to Cart" button, there is no instance of it,
            // but if the user do fast succsessive clicks, there would be other instances of it so PCI cardinality needs to be considered
            return checkCardinalityForAddOrClone(parent, addonChildProduct, product2Id, additionalQuantity);

        } else {

            // If there is no cardinality map in the parent, then it means this Addon will be the only one under the parent.
            // Simply check if the additional quantity would exceed groupMaxQuantity to decide if addToCart on this Addon is allowed.
            groupCardinalityCheckPassed = additionalQuantity <= parent.groupMaxQuantity;
            return groupCardinalityCheckPassed;

        }
    };

    var checkCardinalityForAddOrClone = function (parent, lineItemChildProduct, product2Id, additionalQuantity) {
        var parentInCartQuantityMap = parent[$scope.nsPrefix + 'InCartQuantityMap__c'].value;
        var numOfInstancesOfChildProductTypeUnderParent;

        if (parentInCartQuantityMap)
            numOfInstancesOfChildProductTypeUnderParent = parentInCartQuantityMap[product2Id];

        // If this is lineItem, numOfInstancesOfChildProductTypeUnderParent would have a value for us to check PCI Cardinality.
        // If this is Addon, it would be undefined and we would set PCI check to be true so it could move on to check Group cardinality.
        var pciCardinalityCheckPassed =
            (typeof numOfInstancesOfChildProductTypeUnderParent !== 'undefined') ? numOfInstancesOfChildProductTypeUnderParent + additionalQuantity <= lineItemChildProduct.maxQuantity : true;

        var totalNumOfChildrenUnderParent, productId, groupCardinalityCheckPassed;

        // if PCI cardinality check fails, we cannot let user add or clone
        if (!pciCardinalityCheckPassed) {
            return false;
        }

        if (typeof parent.groupMaxQuantity !== 'undefined') {

            totalNumOfChildrenUnderParent = 0;
            for (productId in parentInCartQuantityMap) {
                if (parentInCartQuantityMap.hasOwnProperty(productId)) {
                    totalNumOfChildrenUnderParent += parentInCartQuantityMap[productId];
                }
            }

            groupCardinalityCheckPassed = totalNumOfChildrenUnderParent + additionalQuantity <= parent.groupMaxQuantity;
            return groupCardinalityCheckPassed;

        } else {

            // this deals with products created before we implemented group cardinality on products
            return true; // pciCardinalityCheckPassed is true

        }
    };

    $scope.checkCardinalityForClone = function (parent, lineItemChildProduct) {
        var product2Id = lineItemChildProduct.PricebookEntry.Product2.Id;
        // clone lineItem will be added with the quantity of the lineItem, except when user typed a 0 which we forbid.
        // In the latter case, we will forbid user from cloning the lineItem.
        var additionalQuantity = lineItemChildProduct.Quantity.value;
        return (additionalQuantity > 0) ? checkCardinalityForAddOrClone(parent, lineItemChildProduct, product2Id, additionalQuantity) : false;
    };

    $scope.checkCardinalityForDelete = function (parent, lineItemChildProduct) {
        var parentInCartQuantityMap = parent[$scope.nsPrefix + 'InCartQuantityMap__c'].value;
        var numOfInstancesOfChildProductTypeUnderParent;
        var pciCardinalityCheckPassed;
        var totalNumOfChildrenUnderParent, productId, groupCardinalityCheckPassed;

        if (parentInCartQuantityMap)
            numOfInstancesOfChildProductTypeUnderParent = parentInCartQuantityMap[lineItemChildProduct.PricebookEntry.Product2.Id];

        // if user typed 0 in quantity input, we will get an undefined value here
        if (typeof lineItemChildProduct.Quantity.value === 'undefined') {
            return true; // we need to let them delete using the delete icon because we forbid them setting quantity to 0
            // if user typed non-zero value in quantity input
        } else {
            pciCardinalityCheckPassed = numOfInstancesOfChildProductTypeUnderParent - lineItemChildProduct.Quantity.value >= lineItemChildProduct.minQuantity;
        }

        // if PCI cardinality check fails, we cannot let user delete
        if (!pciCardinalityCheckPassed) {
            return false;
        }

        if (typeof parent.groupMaxQuantity !== 'undefined') {

            totalNumOfChildrenUnderParent = 0;
            for (productId in parentInCartQuantityMap) {
                if (parentInCartQuantityMap.hasOwnProperty(productId)) {
                    totalNumOfChildrenUnderParent += parentInCartQuantityMap[productId];
                }
            }

            groupCardinalityCheckPassed = totalNumOfChildrenUnderParent - lineItemChildProduct.Quantity.value >= parent.groupMinQuantity;
            return groupCardinalityCheckPassed;

        } else {

            // this deals with products created before we implemented group cardinality on products
            return true; // pciCardinalityCheckPassed is true

        }
    };

    //################ Cardinality Section End ################

    var className = bpService.sNSC + 'CpqAppHandler';
    $scope.addProductFromCart = function (parent, obj, gParent) {
        var configAddObject = { 'records': [{}] }, // addToCart attributes API structure
            deleteArrayList = ['Attachments', 'actions', 'messages', 'childProducts', 'lineItems', 'attributeCategories', 'childRecords'],
            parentInCardData = parent,
            parentFromAPI, lineItemToBeAdded,
            opt = {},
            inputParam = Object.keys(obj.actions.addtocart.remote.params).length > 0 ? obj.actions.addtocart.remote.params : (Object.keys(obj.actions.addtocart.rest.params).length > 0 ? obj.actions.addtocart.rest.params : null);

        /*
            In this addToCart, indeed there are two kind of objects that can be added:
            1) Required products lineItems and Optional products lineItems (that have been added to cart) will have an + icon (if cardinality check succeeds)
                For these products to be added again, need to use checkCardinalityForAdd()
            2) Optional products (minQuantity=0) that are not added to cart. In this case, they should be using checkCardinalityForAddon()
            To detect case 1: check if (obj.itemType === 'lineItem'): they are in lineItems
            To detect case 2: check if (obj.itemType === 'childProducts'): they are in childProducts
        */

        var product2Name = (obj.itemType === 'lineItem') ? obj.PricebookEntry.Product2.Name : obj.Product2.Name;
        var passedCardinality = (obj.itemType === 'lineItem') ? $scope.checkCardinalityForAdd(parentInCardData, obj) : $scope.checkCardinalityForAddon(parentInCardData, obj);
        if (!passedCardinality) {
            alert('Cardinality error: CPQAddItemFailed For :' + product2Name);
            return;
        }

        configAddObject.records[0] = angular.copy(parent);
        angular.forEach(deleteArrayList, function (key) {
            delete configAddObject.records[0][key];
        });

        inputParam.items[0].parentRecord = configAddObject;
        inputParam.items[0].fieldsToUpdate = {
            %vlocity_namespace%__ServiceAccountId__c: $scope.bpTree.response.CurrentLocationId
        };
        inputParam.hierarchy = 20;

        $rootScope.loading = true;
        var configObj = {
            sClassName: 'ftr_CpqService', sMethodName: 'invokeCpqAppHandlerMethod', input: angular.toJson(inputParam),
            options: angular.toJson(opt), iTimeout: null, label: null
        };
        bpService.OmniRemoteInvoke(configObj).then(
            function (result) {
                var configObjCart = {
                    sClassName: className, sMethodName: 'getCarts', input: angular.toJson(inputParam),
                    options: angular.toJson(opt), iTimeout: null, label: null
                };
                bpService.OmniRemoteInvoke(configObjCart).then(
                    function (result) {
                        $rootScope.loading = false;
                        var resp = angular.fromJson(result), bundlehasError = false, msgArry = [], msgIdArray;
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex] + '_Top'] = [resp];
                        $scope.showErrorIconInCart($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'][0].messages, $scope);

                        angular.forEach(resp.messages, function (message) {
                            msgIdArray = message.messageId.split('|');
                            if (message.severity === 'ERROR' && gParent && gParent.Id.value == msgIdArray[0] && gParent['PricebookEntry']['Product2Id'] == msgIdArray[1]) {
                                bundlehasError = true;
                                msgArry.push(message);
                            }
                        });
                        if (bundlehasError && gParent)
                            gParent.messages = msgArry;
                    },
                    function (error) {
                        $scope.handleRemoteCallError(null, error, true, false);
                    }
                );
                var resp = angular.fromJson(result);
                resp = angular.fromJson(resp.result);
                var hasError = false, errorMsg = '';
                angular.forEach(resp.messages, function (message) {
                    if (message.severity === 'ERROR') {
                        hasError = true;
                        errorMsg = message.message;
                    }
                });

                if (hasError && !resp.records) {
                    $scope.handleRemoteCallError(null, errorMsg, true, false);
                    return;
                }
                parentFromAPI = resp.records[0];
                // We must copy the entire map object (not just value property) in addToCart because for a parent
                // with ONLY optional products with defaultQuantity=0 (in main cart), there is NO map to start with.  The entire map
                // is needed for subsequent update of any of its children.  The updateItemsAPI expects all properties
                // of the map to be passed to it
                parentInCardData[$scope.nsPrefix + 'InCartQuantityMap__c'] = parentFromAPI[$scope.nsPrefix + 'InCartQuantityMap__c'];
                toBeAddedLineItem = parentFromAPI.lineItems.records[0];
                insertLineItemToParent(parentInCardData, toBeAddedLineItem);
                $scope.initParent($scope, parentInCardData);
            },
            function (error) {
                $scope.handleRemoteCallError(null, error, true, false);
            }
        );
    };

    var insertLineItemToParent = function (parentInCardData, toBeAddedLineItem) {
        var addonList;
        var lineItemListWithTheAddedItem = [];
        if (!parentInCardData.lineItems) {
            parentInCardData.lineItems = { 'records': [{}] };
        } else {
            lineItemListWithTheAddedItem = angular.copy(parentInCardData.lineItems.records);
        }
        lineItemListWithTheAddedItem.push(toBeAddedLineItem);
        parentInCardData.lineItems.records = lineItemListWithTheAddedItem;

        // 1) If the to-be-added lineItem is an Optional product (Definition: minQuantity=0) and has defaultQuantity > 0,
        // that means it was a lineItem initially because defaultQuantity > 0,
        // but subsequently it was deleted and was removed from lineItems json array, but was added to as an Addon
        // in childProducts array.  Now that we are adding it back to lineItems, we also need to remove
        // the corresponding Addon in childProducts.
        // 2) We don't need to do this for Optional products (Definition: minQuantity=0) and have defaultQuantity = 0, because
        // they always have an Addon in the childProducts array.
        // 3) We also do not need to do this for Required products (Definition: minQuantity>0) as they cannot be
        // completely deleted and would never have a representation in the childProducts array.
        if ((toBeAddedLineItem.minQuantity === undefined || toBeAddedLineItem.minQuantity === 0) && toBeAddedLineItem.defaultQuantity > 0) {
            removeAddonFromParent(parentInCardData, toBeAddedLineItem.PricebookEntryId.value);
        }
    };

    var removeAddonFromParent = function (parentInCardData, toBeRemovedAddonId) {
        var addonList;
        var addonListWithoutTheRemovedAddon = [];
        var i;
        if (parentInCardData.childProducts) {
            addonList = angular.copy(parentInCardData.childProducts.records);
            for (i = 0; i < addonList.length; i++) {
                if (addonList[i].Id.value !== toBeRemovedAddonId) {
                    addonListWithoutTheRemovedAddon.push(addonList[i]);
                }
            }
            parentInCardData.childProducts.records = addonListWithoutTheRemovedAddon;
        }
    };

    $scope.deleteProductFromCart = function (parent, product, index, gParent) {
        var opt = {},
            parentInCardData, itemObject,
            addonProduct,
            cardinalityMapAlreadyUpdated,
            inputParam = Object.keys(product.actions.deleteitem.remote.params).length > 0 ? product.actions.deleteitem.remote.params : (Object.keys(product.actions.deleteitem.rest.params).length > 0 ? product.actions.deleteitem.rest.params : null);

        $rootScope.loading = true;
        var configObj = {
            sClassName: 'ftr_CpqService', sMethodName: 'invokeCpqAppHandlerMethod', input: angular.toJson(inputParam),
            options: angular.toJson(opt), iTimeout: null, label: null
        };
        bpService.OmniRemoteInvoke(configObj).then(
            function (result) {
                console.info('Deleted');
                // deleteOrUpdateProductFromProductsListAddedToCart('delete', parent, product);

                var configObjCart = {
                    sClassName: className, sMethodName: 'getCarts', input: angular.toJson(inputParam),
                    options: angular.toJson(opt), iTimeout: null, label: null
                };
                // console.log(result);
                // var res = angular.fromJson(result.result);
                // if (res.messages && res.messages[0] && res.messages[0].severity == 'ERROR') {
                //     errorMessage = res.messages[0].message; 
                // }
                bpService.OmniRemoteInvoke(configObjCart).then(
                    function (res) {
                        $rootScope.loading = false;
                        var resp = angular.fromJson(res), msgArry = [], msgIdArray;
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex] + '_Top'] = [resp];
                        $scope.showErrorIconInCart($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'][0].messages, $scope);

                        angular.forEach(resp.messages, function (message) {
                            msgIdArray = message.messageId.split('|');
                            if (message.severity === 'ERROR' && gParent && gParent.Id.value == msgIdArray[0] && gParent['PricebookEntry']['Product2Id'] == msgIdArray[1])
                                msgArry.push(message);
                        });
                        if (gParent)
                            gParent.messages = msgArry;
                        var configObjCartItems = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCartsItems', 
                            input: angular.toJson({ price:false, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                            options: angular.toJson(opt), 
                            iTimeout: null
                        };
                        bpService.OmniRemoteInvoke(configObjCartItems).then(
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
                        $scope.handleRemoteCallError(null, error, true, false);
                    }
                );
                var data = angular.fromJson(result),
                    hasError = false;
                
                data = JSON.parse(data.result);
                angular.forEach(data.messages, function (message) {
                    if (message.severity === 'ERROR') {
                        hasError = true;
                        deleteErrorMsg = message.message;
                    }
                });
                console.info('error: ', hasError);
                if (!hasError) {
                    console.info('NO ERROR');
                    deleteOrUpdateProductFromProductsListAddedToCart('delete', parent, product);
                    if (!data.records || data.records.length === 0) {
                        console.info('dataRecord0 ###################');
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex]].records.splice(index, 1);
                    } else {
                        console.info('dataRecord>0 ###################');
                        parentInCardData = parent;
                        itemObject = product;
                        // if there is another instance of the same product type to be deleted in lineItems,
                        // API would not return addonProduct
                        if (data.records[0].childProducts) {
                            addonProduct = data.records[0].childProducts.records[0];
                        } else {
                            addonProduct = null;
                        }

                        cardinalityMapAlreadyUpdated = false;
                        deleteLineItem(parentInCardData, itemObject, addonProduct, cardinalityMapAlreadyUpdated);

                        $scope.initParent($scope, parentInCardData);
                    }
                } else if (deleteErrorMsg !== '') {
                    // alert(deleteErrorMsg);
                    console.info('ERROR');
                    $scope.handleRemoteCallError(null, deleteErrorMsg, true, false);
                }
                $scope.closeAttributePanel();
            },
            function (error) {
                console.info('FUNCTION ERROR????????');
                $scope.handleRemoteCallError(null, error, true, false);
            }
        );
    }

    function deleteOrUpdateProductFromProductsListAddedToCart(actionType, parent, product) {
        for (var i = 0; i < $scope.bpTree.response.productsListAddedToCart.length; i++) {
            if (parent && RC_ADD_ON_SERVICES_LIST.indexOf(parent.ProductCode) != -1) {
                for (var j = 0; j < $scope.bpTree.response.productsListAddedToCart[i].childRecords.length; j++) {
                    if ($scope.bpTree.response.productsListAddedToCart[i].childRecords[j].ProductCode == product.ProductCode) {
                        if (actionType == 'delete') {
                            $scope.bpTree.response.productsListAddedToCart[i].childRecords.splice(j,1);
                        } else if (actionType == 'update') {
                            $scope.bpTree.response.productsListAddedToCart[i].childRecords[j].Quantity.value = product.Quantity.value;
                        }
                        return;
                    };
                }
            } else if ($scope.bpTree.response.productsListAddedToCart[i].ProductCode == product.ProductCode) {
                if (actionType == 'delete') {
                    $scope.bpTree.response.productsListAddedToCart.splice(i,1);
                } else if (actionType == 'update') {
                    $scope.bpTree.response.productsListAddedToCart[i].Quantity.value = product.Quantity.value;
                }
                return;
            }
        }

    }

    var changeLineItemCountInCardinalityMap = function (cardinalityMap, product2Id, changeQty) {
        var productCountInMap = cardinalityMap[product2Id];
        var productCountAfterChange;
        if (productCountInMap) {
            productCountAfterChange = productCountInMap + changeQty;
            if (productCountAfterChange > 0) {
                cardinalityMap[product2Id] = productCountAfterChange;
            } else {
                delete cardinalityMap[product2Id];
            }
        }
    };

    var removeLineItemFromParent = function (parentInCardData, toBeRemovedLineItemId, addonProductFromAPI) {
        var lineItemList;
        var lineItemListWithoutTheRemovedItem = [];
        var i;
        var currentLineItem;

        if (parentInCardData.lineItems) {

            lineItemList = angular.copy(parentInCardData.lineItems.records);
            for (i = 0; i < lineItemList.length; i++) {
                currentLineItem = lineItemList[i];
                if (currentLineItem.Id.value !== toBeRemovedLineItemId) {
                    lineItemListWithoutTheRemovedItem.push(currentLineItem);
                }
            }

            // Delete the lineItem from parent by replacing the existing lineItems under the parent
            // by an array without the to-be-deleted lineItem
            parentInCardData.lineItems.records = lineItemListWithoutTheRemovedItem;

        }
    };

    var deleteLineItem = function (parentInCardData, toBeRemovedLineItem, addonProductFromAPI, cardinalityMapAlreadyUpdated) {
        var toBeRemovedLineItemId = toBeRemovedLineItem.Id.value;
        var parentInCardDataCardinalityMap, toBeRemovedLineItemProduct2Id, toBeRemovedLineItemQuantity;
        var addonProductIsLastInstanceUnderParent;
        var numOfLineItemsUnderParent, numOfChildProductsUnderParent;
        var i, j;

        if (!cardinalityMapAlreadyUpdated) {
            parentInCardDataCardinalityMap = parentInCardData[$scope.nsPrefix + 'InCartQuantityMap__c'].value;
            toBeRemovedLineItemProduct2Id = toBeRemovedLineItem.PricebookEntry.Product2.Id;
            toBeRemovedLineItemQuantity = toBeRemovedLineItem.Quantity.value;
            if (parentInCardDataCardinalityMap) {
                changeLineItemCountInCardinalityMap(parentInCardDataCardinalityMap, toBeRemovedLineItemProduct2Id, toBeRemovedLineItemQuantity * -1);
            }
        }

        removeLineItemFromParent(parentInCardData, toBeRemovedLineItemId, addonProductFromAPI);

        // 1) Only Optional products (Definition: minQuantity=0) with defaultQuantity > 0 would need to be put into childProducts
        // if there is NONE OTHER instance of it under the parent, such that it would show up with "Add to Cart" button.
        // 2) For Optional products (Definition: minQuantity=0) with defaultQuantity = 0,
        // they are always in childProducts and addonProduct returned from the deleteAPI would be null.
        // 3) Required products (Definition: minQuantity>0) would never have a representation in the childProducts array
        // and addonProduct returned from the deleteAPI would be null.

        // For Case 1: Optional products (Definition: minQuantity=0) with defaultQuantity > 0
        if (addonProductFromAPI && (addonProductFromAPI.minQuantity === undefined || addonProductFromAPI.minQuantity === 0) && addonProductFromAPI.defaultQuantity > 0) {

            // Only do the following to remove the childProduct representation of the lineItem if parent is NOT collapsable
            if (!parentInCardData.actions || (parentInCardData.actions && !parentInCardData.actions.getproducts)) {

                // Check to see if addonProduct is the last instance under the parent
                addonProductIsLastInstanceUnderParent = true;
                numOfLineItemsUnderParent = parentInCardData.lineItems.records.length;
                for (i = 0; i < numOfLineItemsUnderParent; i++) {
                    if (parentInCardData.lineItems.records[i].PricebookEntry.Product2.Id === addonProductFromAPI.Product2.Id) {
                        addonProductIsLastInstanceUnderParent = false;
                    }
                }

                // Only insert addonProduct into childProducts if it is the last instance of its product2 type under the parent,
                // because this is Case 1: Optional products (Definition: minQuantity=0) with defaultQuantity > 0,
                // as such, ONLY 1 addon needs to be in childProducts
                if (addonProductIsLastInstanceUnderParent) {

                    if (!parentInCardData.childProducts) {
                        parentInCardData.childProducts = {};
                        parentInCardData.childProducts.records = [];
                    }

                    parentInCardData.childProducts.records.push(addonProductFromAPI);
                }

            }

            // For Case 2: Optional products (Definition: minQuantity=0) with defaultQuantity = 0
        } else if (addonProductFromAPI && (addonProductFromAPI.minQuantity === undefined || addonProductFromAPI.minQuantity === 0) && addonProductFromAPI.defaultQuantity === 0) {

            if (parentInCardData.actions && parentInCardData.actions.getproducts) {
                // remove childProduct from parent if the parent is Collapsable
                removeAddonFromParent(parentInCardData, toBeRemovedLineItem.PricebookEntryId.value);
            } else {

                // Replace it by the (updated) one from API
                numOfChildProductsUnderParent = parentInCardData.childProducts.records.length;
                for (j = 0; j < numOfChildProductsUnderParent; j++) {
                    if (parentInCardData.childProducts.records[j].Product2.Id === addonProductFromAPI.Product2.Id) {
                        parentInCardData.childProducts.records[j] = addonProductFromAPI;
                        break;
                    }
                }

            }

        }

    };

    $scope.clone = function (parent, itemObject) {
        var configCloneObject = { 'records': [{}] }; // clone API structure
        var deleteArrayList = ['Attachments', 'actions', 'messages', 'childProducts', 'lineItems', 'attributeCategories', 'childRecords'];
        var cloneActionObj = Object.keys(itemObject.actions.cloneitem.remote.params).length > 0 ? itemObject.actions.cloneitem.remote.params : (Object.keys(itemObject.actions.cloneitem.rest.params).length > 0 ? itemObject.actions.cloneitem.rest.params : null);
        var parentInCardData = parent;
        var parentFromAPI, lineItemToBeAdded;
        var processingToastMessage, opt = {};

        // Only lineItems could be cloned and they would have the 'PricebookEntry' field.
        var product2Name = itemObject.PricebookEntry.Product2.Name;

        // Only check cardinality if the item being cloned is a non-root lineItem and would therefore have a ParentItemId__c field with value
        if (itemObject[$scope.nsPrefix + 'ParentItemId__c'] && itemObject[$scope.nsPrefix + 'ParentItemId__c'].value) {

            /*
                Only lineItems can be cloned and they would be:
                Required products lineItems and Optional products lineItems (that have been added to cart) will have an clone icon (if cardinality check succeeds)
                    For these products to be cloned, need to use checkCardinalityForAdd()
            */
            var product2Name = (itemObject.itemType === 'lineItem') ? itemObject.PricebookEntry.Product2.Name : itemObject.Product2.Name;
            var passedCardinality = $scope.checkCardinalityForClone(parentInCardData, itemObject);
            if (!passedCardinality) {
                alert('Cardinality error: CPQAddItemFailed For :' + product2Name);
                return;
            }

        }

        cloneActionObj.items = [
            { 'itemId': itemObject.Id.value }
        ];

        if (parent) {

            configCloneObject.records[0] = angular.copy(parent);
            angular.forEach(deleteArrayList, function (key) {
                delete configCloneObject.records[0][key];
            });

            cloneActionObj.items[0].parentRecord = configCloneObject;

        }

        cloneActionObj.hierarchy = 20;

        $rootScope.loading = true;
        var configObj = {
            sClassName: className, sMethodName: 'cloneItems', input: angular.toJson(cloneActionObj),
            options: angular.toJson(opt), iTimeout: null, label: null
        };
        bpService.OmniRemoteInvoke(configObj).then(
            function (result) {
                var configObjCart = {
                    sClassName: className, sMethodName: 'getCarts', input: angular.toJson(cloneActionObj),
                    options: angular.toJson(opt), iTimeout: null, label: null
                };
                bpService.OmniRemoteInvoke(configObjCart).then(
                    function (res) {
                        $rootScope.loading = false;
                        var resp = angular.fromJson(res);
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex] + '_Top'] = [resp];
                        $scope.showErrorIconInCart($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'][0].messages, $scope);
                        
                        var configObjCartItems = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCartsItems', 
                            input: angular.toJson({ price:false, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                            options: angular.toJson(opt), 
                            iTimeout: null
                        };
                        bpService.OmniRemoteInvoke(configObjCartItems).then(
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
                        $scope.handleRemoteCallError(null, error, true, false);
                    }
                );
                var data = angular.fromJson(result);
                // the root bundle is cloned and the response from API would have a root bundle that has its root being itself (RootItemId__c.value === Id.value)
                if (data.records[0][$scope.nsPrefix + 'RootItemId__c'] && data.records[0][$scope.nsPrefix + 'RootItemId__c'].value &&
                    (data.records[0][$scope.nsPrefix + 'RootItemId__c'].value === data.records[0].Id.value)) {

                    // add the whole root bundle to the cart
                    $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex]].records.unshift(data.records[0]);

                    // a lineItem is cloned and a skinny response object is returned with Id, cardinality map, lineItems
                } else {

                    parentFromAPI = data.records[0];
                    parentInCardData[$scope.nsPrefix + 'InCartQuantityMap__c'] = parentFromAPI[$scope.nsPrefix + 'InCartQuantityMap__c'];
                    toBeAddedLineItem = parentFromAPI.lineItems.records[0];
                    insertLineItemToParent(parentInCardData, toBeAddedLineItem);
                    $scope.initParent($scope, parentInCardData);
                }
            },
            function (error) {
                $scope.handleRemoteCallError(null, error, true, false);
            }
        );
    };

    $scope.lineItemIdsWithInvalidQuantity = [];
    $scope.updateLineField = function (parent, itemObject, quantity, updateAttributeData) {
        var oldQuantity = angular.copy(itemObject.Quantity.value);
        console.log(oldQuantity);
        var updateItemsActionObj = {};
        var loadMessage = { 'event': 'setLoading', 'message': true };
        var configUpdateObject = { 'records': [{}] }; // Update attributes API structure
        var deleteArrayList = ['Attachments', 'actions', 'messages', 'childProducts', 'lineItems', 'childRecords'];
        var modifiedChildItemObject;
        var parentFromAPI, parentInCardData;
        var updatedLineItemFromAPI, updatedLineItemInCarddata;
        var addonProduct;
        var cardinalityMapAlreadyUpdated, opt = {};

        if (quantity)
            itemObject.Quantity.value = quantity;

        if (quantity === 0)
            return;

        var errorMessage = lineFieldValidation(itemObject);
        itemObject.fieldValidationMessage = '';

        if (errorMessage) {
            itemObject.fieldValidationMessage = errorMessage;
            return;
        }

        if (parent) {
            // update on a lineItem that has a parent
            configUpdateObject.records[0] = angular.copy(parent);
            angular.forEach(deleteArrayList, function (key) {
                delete configUpdateObject.records[0][key];
            });

            modifiedChildItemObject = angular.copy(itemObject);
            angular.forEach(deleteArrayList, function (key) {
                delete modifiedChildItemObject[key];
            });

            configUpdateObject.records[0].lineItems = { 'records': [modifiedChildItemObject] };
        } else {
            // update on the root which has no parent
            configUpdateObject.records[0] = angular.copy(itemObject);
            angular.forEach(deleteArrayList, function (key) {
                delete configUpdateObject.records[0][key];
            });
        }

        updateItemsActionObj = Object.keys(itemObject.actions.updateitems.remote.params).length > 0 ? itemObject.actions.updateitems.remote.params : (Object.keys(itemObject.actions.updateitems.rest.params).length > 0 ? itemObject.actions.updateitems.rest.params : null);;
        //Updated items for both remote and rest
        updateItemsActionObj.items = configUpdateObject;

        $rootScope.loading = true;
        // var configObj = {
        //     sClassName: className, sMethodName: 'putCartsItems', input: angular.toJson(updateItemsActionObj),
        //     options: angular.toJson(opt), iTimeout: null, label: null
        // };

        var configObj = {
            sClassName: 'ftr_CpqService', 
            sMethodName: 'invokeCpqAppHandlerMethod', 
            input: angular.toJson(updateItemsActionObj),
            options: angular.toJson(opt), 
            iTimeout: null, 
            label: null
        };


        bpService.OmniRemoteInvoke(configObj).then(
            function (result) {
                deleteOrUpdateProductFromProductsListAddedToCart('update', parent, itemObject);

                var configObjCart = {
                    sClassName: className, sMethodName: 'getCarts', input: angular.toJson(updateItemsActionObj),
                    options: angular.toJson(opt), iTimeout: null, label: null
                };
                bpService.OmniRemoteInvoke(configObjCart).then(
                    function (res) {
                        resp = angular.fromJson(res);
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[$scope.vlcPC.pcIndex] + '_Top'] = [resp];
                        $scope.showErrorIconInCart($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'][0].messages, $scope);
                        var configObjCartItems = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCartsItems', 
                            input: angular.toJson({ price:true, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                            options: angular.toJson(opt), 
                            iTimeout: null
                        };
                        bpService.OmniRemoteInvoke(configObjCartItems).then(
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
                        $scope.handleRemoteCallError(null, error, true, false);
                    }
                );

                var data = angular.fromJson(result);
                console.log('putCartsItems result',data);
                var updateSuccessful = false;
                var hasError = false;
                var errorMessage = '';
                parentInCardData = parent;

                angular.forEach(data.messages, function (message) {
                    if (message.severity === 'ERROR') {
                        hasError = true;
                        errorMessage = message.message;
                    }

                    if (message.severity === 'INFO' && message.code === '151')
                        updateSuccessful = true;

                });

                if (hasError) {
                    $scope.handleRemoteCallError(null, errorMessage);
                }

                // root is updated when the response has no lineItems and (no parentItemId (in modal) or parentItemId is null (in cart)
                if (!data.records[0].lineItems && (!data.records[0][$scope.nsPrefix +
                    'ParentItemId__c'] || !data.records[0][$scope.nsPrefix + 'ParentItemId__c'].value)) {

                    if (errorMessage.includes('Quantity') || errorMessage.includes('quantity')) {
                        data.records[0].Quantity.value = oldQuantity;
                    }

                    // copy fields including messages
                    updatedLineItemFromAPI = data.records[0];
                    updatedLineItemInCardData = itemObject;
                    updatedLineItemInCardData.messages = updatedLineItemFromAPI.messages;
                    copyUpdatableFields(updatedLineItemInCardData, updatedLineItemFromAPI, updateAttributeData);

                    // non-root is updated
                } else {

                    // copy fields including messages
                    parentFromAPI = data.records[0];
                    updatedLineItemFromAPI = data.records[0].lineItems.records[0];
                    updatedLineItemInCardData = findLineItem(updatedLineItemFromAPI.Id.value, parentInCardData.lineItems.records);
                    updatedLineItemInCardData.messages = updatedLineItemFromAPI.messages;
                    //API knows best
                    parentInCardData.messages = parentFromAPI.messages;

                    if (errorMessage.includes('Quantity') || errorMessage.includes('quantity')) {
                        updatedLineItemInCardData.Quantity.value = oldQuantity;
                    }

                    // Attempted quantity change of lineItem must have violated Group cardinality check since the UI
                    // has checked for PCI cardinality violation via lineFieldValidation() in this controller
                    if (parentFromAPI.messages.length && parentFromAPI.messages[0].code === '142') {
                        // then record the quantity invalid if it has not been done before
                        recordLineItemQuantityInvalid(updatedLineItemFromAPI);

                        // this is the case when update is successful BUT there is other error such as required product attribuyte missing
                    } else if (updateSuccessful) {

                        parentInCardData[$scope.nsPrefix + 'InCartQuantityMap__c'] = parentFromAPI[$scope.nsPrefix + 'InCartQuantityMap__c'];
                        copyUpdatableFields(updatedLineItemInCardData, updatedLineItemFromAPI, updateAttributeData);

                        // Now that update is successful, lineItem Quantity field must have passed Group cardinality check by API,
                        // so mark it valid in case it was invalid before
                        recordLineItemQuantityValid(updatedLineItemFromAPI);

                    }

                }
            },
            function (error) {
                $scope.handleRemoteCallError(null, error, true, false);
            }
        );
    };

    var recordLineItemQuantityInvalid = function (item) {
        if (!_.includes($scope.lineItemIdsWithInvalidQuantity, item.Id.value)) {
            $scope.lineItemIdsWithInvalidQuantity.push(item.Id.value);
        }
    };

    var recordLineItemQuantityValid = function (item) {
        recordLineItemFieldValid($scope.lineItemIdsWithInvalidQuantity, item);
    };

    var recordLineItemFieldValid = function (invalidList, item) {
        if (_.includes(invalidList, item.Id.value)) {
            _.pull(invalidList, item.Id.value);
        }
    };

    var copyUpdatableFields = function (targetLineItem, sourceLineItem, updateAttributeData) {
        targetLineItem.Quantity.value = sourceLineItem.Quantity.value;
        targetLineItem[$scope.nsPrefix + 'RecurringTotal__c'].value = sourceLineItem[$scope.nsPrefix + 'RecurringTotal__c'].value;
        targetLineItem[$scope.nsPrefix + 'OneTimeTotal__c'].value = sourceLineItem[$scope.nsPrefix + 'OneTimeTotal__c'].value;
        targetLineItem[$scope.nsPrefix + 'RecurringManualDiscount__c'].value = sourceLineItem[$scope.nsPrefix + 'RecurringManualDiscount__c'].value;
        targetLineItem[$scope.nsPrefix + 'OneTimeManualDiscount__c'].value = sourceLineItem[$scope.nsPrefix + 'OneTimeManualDiscount__c'].value;
        targetLineItem.messages = sourceLineItem.messages;
        if (updateAttributeData) {
            targetLineItem.attributeCategories = sourceLineItem.attributeCategories;
        }
    };

    var findLineItem = function (searchLineItemId, lineItemList) {
        var foundLineItem = null;
        var i, j;
        for (i = 0; i < lineItemList.length; i++) {
            if (lineItemList[i].Id.value === searchLineItemId) {
                foundLineItem = lineItemList[i];
                break;
            }
        }
        if (foundLineItem !== null) {
            return foundLineItem;
        } else {
            for (j = 0; j < lineItemList.length; j++) {
                if (lineItemList[j].lineItems && lineItemList[j].lineItems.records.length > 0) {
                    return findLineItem(searchLineItemId, lineItemList[j].lineItems.records);
                }
            }
        }
    };

    var lineFieldValidation = function (item) {
        var msg = '';
        var label;

        var recurringValue = item[$scope.nsPrefix + 'RecurringManualDiscount__c'].value;
        var oneTimeValue = item[$scope.nsPrefix + 'OneTimeManualDiscount__c'].value;

        var recurringDiscount = (recurringValue !== undefined && recurringValue !== null) ? true : false;
        var oneTimeDiscount = (oneTimeValue !== undefined && oneTimeValue !== null) ? true : false;
        var isDiscountValid = (recurringDiscount && oneTimeDiscount) ? true : false;
        var isQuantityValid = (item.Quantity.value && item.Quantity.value >= 1) ? true : false;

        // label
        if (!isQuantityValid) {
            label = item.Quantity.label;
        } else if (!recurringDiscount) {
            label = item[$scope.nsPrefix + 'RecurringManualDiscount__c'].label;
        } else if (!oneTimeDiscount) {
            label = item[$scope.nsPrefix + 'OneTimeManualDiscount__c'].label;
        }

        // message
        if (!isQuantityValid) {
            msg = label + ' cannot be set to 0. Please use the delete option if you would like to delete the item.';
            // Record the lineItemId has an invalid quantity if it has not been done
            recordLineItemQuantityInvalid(item);
        } else if (!isDiscountValid) {
            msg = label + ' cannot be empty.';
        } else if (item.Quantity.value < item.minQuantity) {
            msg = item.Name + ' can not have less than ' + item.minQuantity + ' quantity.';
            // Record the lineItemId has an invalid quantity if it has not been done
            recordLineItemQuantityInvalid(item);
        } else if (item.Quantity.value > item.maxQuantity) {
            msg = item.Name + ' can not have more than ' + item.maxQuantity + ' quantity.';
            // Record the lineItemId has an invalid quantity if it has not been done
            recordLineItemQuantityInvalid(item);
        }

        return msg;
    };

    //### VDF Section Start ###

    // Vlocity Dynamic form mapping object
    $scope.mapVDFObject = function () {
        return {
            'fieldMapping': {
                'type': 'inputType',
                'value': 'userValues',
                'label': 'label',
                'readonly': 'readonly',
                'required': 'required',
                'disabled': 'disabled',
                'hidden': 'hidden',
                'multiple': 'multiselect',
                'customTemplate': 'customTemplate',
                'valuesArray': { //multiple values map. Eg: select, fieldset, radiobutton group
                    'field': 'values',
                    'value': 'value',
                    'label': 'label',
                    'disabled': 'disabled'
                }
            },
            'pathMapping': {
                'levels': 2,
                'path': 'productAttributes.records'
            }
        };
    };

    /*********** CPQ CART ITEM CONFIG EVENTS ************/
    $scope.openConfigPan = function (parent, gParent, itemObject, isConfigEnabled) {
        var itemKeys, lookupItem, editableItem, lookupDisplayValueItemKey, cartId, lineItemId;
        $scope.reRenderAttributesForm = false;
        $scope.configAttributeObj = null;
        $scope.configItemObject = itemObject;
        $scope.parent = parent;
        $scope.gParent = gParent;

        if (!isConfigInProcess)
            queue = [];
        else
            removeQueueElement();

        $timeout(function () {
            if (isConfigEnabled && itemObject) {
                $scope.configAttributeObj = itemObject.attributeCategories && itemObject.attributeCategories.records || [];
                // // remove hidden attributes from config panel - Eric
                // if ($scope.configAttributeObj != null){
                //     var tempList = [...$scope.configAttributeObj];
                //     for (let i=0; i < $scope.configAttributeObj[0].productAttributes.records.length; i++) {
                //         if ($scope.configAttributeObj[0].productAttributes.records[i].hidden) {
                //             tempList[0].productAttributes.records.splice(i, 1);
                //         }
                //     }
                //     $scope.configAttributeObj = [tempList[0]];
                // }
                updatedAttributes = $scope.attributesObj;
                $scope.reRenderAttributesForm = isConfigEnabled;
                //Set reRenderAttributesForm to false on new load. If user closes

                queue.push({
                    parent: $scope.parent,
                    gParent: $scope.gParent,
                    configItem: $scope.configItemObject,
                    updatedAttributes: $scope.configAttributeObj
                });

                itemKeys = _.keys(itemObject);
                $scope.lookupItemList = [];
                $scope.editableItemList = [];
                cartId = $scope.bpTree.response.cartId;
                lineItemId = itemObject.Id.value;
                angular.forEach(itemKeys, function (key) {
                    if (itemObject[key].editable && !itemObject[key].hidden) {
                        if (itemObject[key].dataType === 'REFERENCE') {
                            lookupItem = angular.copy(itemObject[key]);
                            lookupDisplayValueItemKey = key.slice(0, -1) + 'r';
                            lookupItem.displayValue = itemObject[lookupDisplayValueItemKey].Name;
                            lookupItem.cartId = cartId;
                            lookupItem.lineItemId = lineItemId;
                            $scope.lookupItemList.push(lookupItem);
                        } else {
                            editableItem = angular.copy(itemObject[key]);
                            $scope.editableItemList.push(editableItem);
                        }
                    }
                });
            } else {
                // Remove the vdf form by resetting the attributes and itemObject
                $scope.configAttributeObj = null;
                $scope.configItemObject = null;
                $scope.reRenderAttributesForm = false;
            }
        }, 0);

    };

    $scope.closeAttributePanel = function () {
        $scope.reRenderAttributesForm = false;
        $scope.configAttributeObj = null;
        $scope.configItemObject = null;
        $scope.parent = null;
        $scope.gParent = null;
        removeQueueElement();
    };

    /*********** END CPQ CART ITEM CONFIG EVENTS ************/

    $scope.getModifiedAttributes = function (e, alwaysRunRules, alwaysSave) {
        var modifyAttributesActionObj = angular.copy($scope.configItemObject.actions.modifyattributes);
        var attributesObj = { 'records': [] };
        var itemObject = angular.copy($scope.configItemObject);
        var cherryPickItemObjectFields = ['attributeCategories', 'Id', 'Product2', 'PricebookEntry', 'PricebookEntryId'];
        var field, modelPath, executeRules, activeInputElement, opt = {};
        removeQueueElement();
        isConfigInProcess = true;
        modelPath = e && e.target && e.target.getAttribute('ng-model');
        field = getFieldObjectFromPath(modelPath);
        executeRules = (angular.isDefined(alwaysRunRules) && alwaysRunRules) ? true : field && field.hasRules;
        if (!executeRules) {
            if (alwaysSave) {
                saveTimeout = $timeout(function () {
                    $scope.configSubmit();
                }, 800);
            }
            return;
        }

        //Update itemObject.attributeCategories but first make sure itemObject has attributes
        if ($scope.configItemObject.attributeCategories && $scope.configItemObject.attributeCategories.records) {
            $scope.configItemObject.attributeCategories.records = $scope.configAttributeObj;
        }
        //Pass only the attribtues and mandatory fields for API to be performant.
        attributesObj.records[0] = _.pick(itemObject, cherryPickItemObjectFields);

        modifyAttributesActionObj.remote.params.items = attributesObj;

        var configObj = {
            sClassName: className, sMethodName: 'putItemAttributes', input: angular.toJson(modifyAttributesActionObj.remote.params),
            options: angular.toJson(opt), iTimeout: null, label: null
        };
        $rootScope.loading = true;
        bpService.OmniRemoteInvoke(configObj).then(
            function (data) {
                $rootScope.loading = false;
                data = angular.fromJson(data);
                var attributesModified = false;
                if (data.records.length > 0) {
                    attributesModified = data.messages.some(function (msg) {
                        return (msg.code === '161');
                    });

                    if (attributesModified) {
                        activeInputElement = document.activeElement;
                        $scope.reRenderAttributesForm = true;

                        // Update attribute categories
                        $scope.configItemObject.attributeCategories = data.records[0].attributeCategories;
                        $scope.configAttributeObj = data.records[0].attributeCategories.records || [];
                        queue[0].updatedAttributes = $scope.configAttributeObj;

                        // Run after the current call stack is executed.
                        // Rerenders VDF to reflect new attribute changes
                        $timeout(function () {
                            $scope.reRenderAttributesForm = false;
                            $timeout(function () {
                                $scope.configSubmit();
                            }, 800);
                        }, 0);
                    } else {
                        //Handle the usecase when hasRules flag is true and attributes are not modified
                        $scope.configSubmit();
                    }
                }
            },
            function (error) {
                $scope.handleRemoteCallError(null, error, true, false);
            }
        );
    };

    $scope.configSubmit = function () {
        var updateItemsActionObj = {};
        var configUpdateObject = { 'records': [{}] }; // Update attributes API structure
        var deleteArrayList = ['Attachments', 'attributes', 'childProducts', 'lineItems', 'childRecords'];
        var opt = {};
        setProcessingLine($scope.configItemObject, true);

        //Update itemObject.attributeCategories but first make sure itemObject has attributes
        if (queue[0].configItem.attributeCategories && queue[0].configItem.attributeCategories.records) {
            queue[0].configItem.attributeCategories.records = queue[0].updatedAttributes;
        }

        if (queue[0].parent) {
            // update on a lineItem that has a parent
            configUpdateObject.records[0] = angular.copy(queue[0].parent);
            angular.forEach(deleteArrayList, function (key) {
                delete configUpdateObject.records[0][key];
            });

            modifiedChildItemObject = angular.copy(queue[0].configItem);
            angular.forEach(deleteArrayList, function (key) {
                delete modifiedChildItemObject[key];
            });

            configUpdateObject.records[0].lineItems = { 'records': [modifiedChildItemObject] };
        } else {
            // update on the root which has no parent
            configUpdateObject.records[0] = angular.copy(queue[0].configItem);
            angular.forEach(deleteArrayList, function (key) {
                delete configUpdateObject.records[0][key];
            });
        }

        updateItemsActionObj = Object.keys(queue[0].configItem.actions.updateitems.remote.params).length > 0 ? queue[0].configItem.actions.updateitems.remote.params : (Object.keys(queue[0].configItem.actions.updateitems.rest.params).length > 0 ? queue[0].configItem.actions.updateitems.rest.params : null);
        //Updated items for both remote and rest
        updateItemsActionObj.items = configUpdateObject;

        //delete extra fluff to fix HYB-761
        delete updateItemsActionObj.items.records[0].actions;

        var configObj = {
            sClassName: 'ftr_CpqService', sMethodName: 'invokeCpqAppHandlerMethod', input: angular.toJson(updateItemsActionObj),
            options: angular.toJson(opt), iTimeout: null, label: null
        };
        $rootScope.loading = true;
        bpService.OmniRemoteInvoke(configObj).then(
            function (res) {
                var configObjCart = {
                    sClassName: className, sMethodName: 'getCarts', input: angular.toJson(updateItemsActionObj),
                    options: angular.toJson(opt), iTimeout: null, label: null
                };
                bpService.OmniRemoteInvoke(configObjCart).then(
                    function (result) {
                        $rootScope.loading = false;
                        var resp = angular.fromJson(result);
                        $scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'] = [resp];
                        $scope.showErrorIconInCart($scope.bpTree.response.vlcPersistentComponent[$scope.bpTree.pcId[0] + '_Top'][0].messages, $scope);
                        var bundlehasError = false, msgArry = [], msgIdArray;
                        angular.forEach(resp.messages, function (message) {
                            if (message.severity === 'ERROR')
                                bundlehasError = true;
                            msgIdArray = message.messageId.split('|');
                            if (message.severity === 'ERROR' && $scope.gParent && $scope.gParent.Id.value == msgIdArray[0] && $scope.gParent['PricebookEntry']['Product2Id'] == msgIdArray[1]) {
                                msgArry.push(message);
                            }
                        });

                        if (!bundlehasError && $scope.gParent)
                            $scope.gParent.messages = resp.messages;
                        if (bundlehasError && $scope.gParent && msgArry.length > 0)
                            $scope.gParent.messages = msgArry;

                        var configObjCartItems = {
                            sClassName: '%vlocity_namespace%.CpqAppHandler', 
                            sMethodName: 'getCartsItems', 
                            input: angular.toJson({ price:false, cartId: $scope.bpTree.response.ContextId, methodName: "getCartsItems"}),
                            options: angular.toJson(opt), 
                            iTimeout: null
                        };
                        bpService.OmniRemoteInvoke(configObjCartItems).then(
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
                        $scope.handleRemoteCallError(control, resp.error, true, false);
                    }
                );
                var data = JSON.parse(res);
                data = JSON.parse(data.result);
                var updatedItemObj = data.records[0];
                var hasError = false;
                var updateSuccessful = false;

                angular.forEach(data.messages, function (message) {
                    if (message.severity === 'ERROR') {
                        hasError = true;
                    }

                    if (message.severity === 'INFO' && message.code === '151') {
                        updateSuccessful = true;
                    }
                });

                if (updateSuccessful) {
                    //Handle check for itemObject existence. If user closes config panel before the update response is received
                    for (var i = 0; i < queue.length; i++) {
                        if (queue[i].configItem && queue[i].configItem.Id.value === data.records[0].Id.value) {
                            // Update API is returning the empty actions object. Deleting actions before merge
                            // as a temporary fix.
                            delete updatedItemObj.actions;
                            _.assign(queue[i].configItem, updatedItemObj);
                            break;
                        } else if (queue[i].parent && queue[i].parent.Id.value === updatedItemObj.Id.value) {
                            angular.copy(updatedItemObj.messages, queue[i].parent.messages);
                            if (queue[i].configItem.Id.value === updatedItemObj.lineItems.records[0].Id.value)
                                _.assign(queue[i].configItem, updatedItemObj.lineItems.records[0]);
                            setProcessingLine(data.records[0], false);
                            break;
                        }
                    }
                }

                setProcessingLine($scope.configItemObject, false);
                isConfigInProcess = false;

            }, function (error) {
                $rootScope.loading = false;
            }
        );

    };

    /**
     * getFieldObjectFromPath returns field based on the ng-model path
     * @param  {string} path
     * @return {Object}
     */
    function getFieldObjectFromPath(path) {
        var firstDotIndex;
        var lastDotIndex;
        if (!path) {
            return;
        }

        lastDotIndex = path.lastIndexOf('.');
        if (lastDotIndex != -1) {
            path = path.substring(0, lastDotIndex);
        }

        return _.get($scope, path);
    }

    function setProcessingLine(obj, flag) {
        if (obj) {
            obj.processingLine = flag;
        }
    }

    function removeQueueElement() {
        if (queue.length > 1) {
            queue.shift();
        }
    }

    // Addition Settings section
    /*
        $scope.launchLineItemLookup = function(lookupItem) {
            var lookupFieldName = lookupItem.fieldName;
            var lookupDisplayValueItemFieldName = lookupFieldName.slice(0, -1) + 'r';
            $scope.selectedLookupItemFieldName = lookupFieldName;
            $scope.originalLookupItem = $scope.configItemObject[lookupFieldName];
            $scope.originalDisplayValueLookupItem = $scope.configItemObject[lookupDisplayValueItemFieldName];
            $rootScope.selectedLookupItem = {
                'Id': lookupItem.value,
                'Name': lookupItem.displayValue
            };
            $rootScope.createNewResultMsg = null;
    
            $sldsModal({
                backdrop: 'static',
                animation: true,
                templateUrl: 'CPQCartItemLookupFieldModal.html',
                show: true,
                onHide: function() {
                    refreshLookupItem();
                }
            });
        };
    
        var refreshLookupItem = function() {
            $log.debug('refreshLookupItem: $rootScope.selectedLookupItem: ', $rootScope.selectedLookupItem);
            var changedFieldName = $scope.selectedLookupItemFieldName;
            var changedToId = $rootScope.selectedLookupItem.Id;
            var changedToValue = $rootScope.selectedLookupItem.Name;
            for (var i = 0; i < $scope.lookupItemList.length; i++) {
                if ($scope.lookupItemList[i].fieldName === changedFieldName) {
                    $scope.lookupItemList[i].value = changedToId;
                    $scope.lookupItemList[i].displayValue = changedToValue;
                    break;
                }
            }
            $log.debug('$scope.originalLookupItem: ', $scope.originalLookupItem);
            $scope.originalLookupItem.value = changedToId;
            $log.debug('$scope.originalDisplayValueLookupItem: ', $scope.originalDisplayValueLookupItem);
            $scope.originalDisplayValueLookupItem.Id = changedToId;
            $scope.originalDisplayValueLookupItem.Name = changedToValue;
            $scope.configSubmit();
        };
    
        $scope.refreshEditableField = function(editableItem, alwaysSave) {
            var error_msg, changedValue, originalEditableItem, isValidFieldValue;
            var recurringValue = $rootScope.nsPrefix + 'RecurringManualDiscount__c';
            var oneTimeValue = $rootScope.nsPrefix + 'OneTimeManualDiscount__c';
            var recurringPrice = $rootScope.nsPrefix + 'RecurringCalculatedPrice__c';
            editableItem.qtyValidationMessage = '';
    
            if (editableItem.fieldName == recurringValue || editableItem.fieldName == oneTimeValue || editableItem.fieldName == recurringPrice) {
                if (editableItem.value >= 0 && editableItem.value < 100) {
                    isValidFieldValue = true;
                } else {
                    isValidFieldValue = false;
                }
            }
    
            if (editableItem.fieldName.toLowerCase() == 'quantity') {
                if (angular.isUndefined(editableItem.value) || editableItem.value < 1) {
                    error_msg = editableItem.fieldName + ' must be greater than 0.';
                } else if (editableItem.value < $scope.configItemObject.minQuantity) {
                    error_msg = editableItem.fieldName + ' cannot have less than ' + $scope.configItemObject.minQuantity + ' quantity.';
                } else if (editableItem.value > $scope.configItemObject.maxQuantity) {
                    error_msg = editableItem.fieldName + ' cannot have more than ' + $scope.configItemObject.maxQuantity + ' quantity.';
                }
            } else if (angular.isDefined(isValidFieldValue) && !isValidFieldValue) {
                error_msg = editableItem.label + ' must be greater than or equal to 0, and smaller than 100.';
            }
    
            if (error_msg) {
                editableItem.qtyValidationMessage = error_msg;
            } else {
                changedValue = editableItem.value;
                originalEditableItem = $scope.configItemObject[editableItem.fieldName];
                originalEditableItem.value = changedValue;
            }
    
            if (!error_msg && alwaysSave) {
                $scope.configSubmit();
            }
        };
    */
    //### VDF Section End ###
    // Show Error messages in top cart
    $scope.showErrorIconInCart = function (msgArr) {
        if (!msgArr) {
            $scope.showErrorIcon = false;
            return;
        }
        for (var i = 0; i < msgArr.length; i++) {
            if (msgArr[i].severity === 'ERROR')
                $scope.showErrorIcon = true;
        }

        if (msgArr.length === 0)
            $scope.showErrorIcon = false;

        $scope.bpTree.response.canOrderCheckout = !$scope.showErrorIcon;

    }
});