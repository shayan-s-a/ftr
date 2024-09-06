vlocity.cardframework.registerModule.controller('cpqprodcartconfigcontroller', ['$scope', '$log', '$q', 'dataSourceService', 'CPQService', 'CPQTranslateService', '$rootScope', '$sldsToast', 'CPQCartItemCrossActionService', 'TRANSLATION_FIELDS', 'CPQUtilityService', '$window', '$timeout', function ($scope, $log, $q, dataSourceService, CPQService, CPQTranslateService, $rootScope, $sldsToast, CPQCartItemCrossActionService, TRANSLATION_FIELDS, CPQUtilityService, $window, $timeout) {
    console.log("inside cpqprodcartconfigCcntroller", $scope.importedScope);
    $scope.doNotShowServiceAcclst = [
        'ENT_ETH_IP_0002',
        'ENT_ETH_MR_001',
        'ENT_ETH_ADV_01',
        'ENT_ETH_CELL_01',
        'ENT_ETH_STD_01',
        'ENT_ETH_WIFI_01',
        'ENT_ETH_WIFI_02'
    ];
    $scope.isAttributeAvailable = function(attributes) {
        var isAttributeSet = false;
        if (attributes && attributes.length > 0) {
            isAttributeSet = true;
        } else {
			isAttributeSet = false;
		}
		return isAttributeSet;
    }
    $scope.checkForActionType = function(importedScope,e, formValidation) {
        var field, fieldName, modelPath, executeRules, activeInputElement, $configContent, scrollPosition,isOffNet;
        if(e.target){
            fieldName = e.target.name;
        }

        if (fieldName && formValidation && formValidation[fieldName].$invalid) {
            isAttrValid = !formValidation[fieldName].$invalid;
            $rootScope.$broadcast('vlocity.layout.invalidate-total-card', {'isValid':isAttrValid});
            return;
        }
        //Avoid angular events from $on. Only need to handle DOM events
        modelPath = e && e.target && e.target.getAttribute('ng-model');
        field = getFieldObjectFromPath(modelPath,importedScope);
        console.log('field===>'+JSON.stringify(field));
        if(field.code == 'ATTR_BANDWIDTH' || field.code == 'ATTR_PARTNER'){
            var attributes = importedScope.attributesObj;
           if (attributes && attributes.length > 0) {
                for(var i = 0; i < attributes.length; i++) {
                    var obj = attributes[i];
                    if(obj) {
                        if(obj.Code__c == 'FTR_ENT_ELIG_ATTCAT'){
                            var records = obj.productAttributes.records;
                            
                            if (records.length >0) {
                                for(var j = 0; j < records.length; j++) {
                                    if(records[j].code == 'ATTR_ELIGBL_PARTNRD'){
                                        isOffNet = records[j].userValues;
                                    }
                                }	
                            }
                        }
                    
                        
                    }
                }
                
            }
            importedScope.getModifiedAttributes(e, formValidation, null, true);
            if(isOffNet){
                $timeout(function () {
                    $window.location.reload();
                    }, 12000);
            }
            
            
        }else{
            importedScope.getModifiedAttributes(e, formValidation, null, true);
            if(isOffNet){
                $timeout(function () {
                    $window.location.reload();
                    }, 12000);
            }
        }
         
    };
     function getFieldObjectFromPath(path,importedScope) {
            var firstDotIndex;
            var lastDotIndex;
            if (!path) {
                return;
            }

            firstDotIndex = path.indexOf('.');
            if (firstDotIndex != -1) {
                path = path.substring(firstDotIndex);
            }

            lastDotIndex = path.lastIndexOf('.');
            if (lastDotIndex != -1) {
                path = path.substring(0, lastDotIndex);
            }
            path = CPQUtilityService.removeIfStartsWith(path, '.');

            return _.get(importedScope, path);
    };
    
// $scope.$on('vlocity.cpq.totalbar.reload', function(event, validation) {
//                 if ($scope.importedScope.configSubmit) {
//                     $rootScope.$broadcast('vlocity.cpq.cart.reload');
//                 }
//             });

}]);