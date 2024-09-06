vlocity.cardframework.registerModule.controller('cpqheadercardController', ['$scope','$rootScope', 'dataService','$q', function($scope, $rootScope, dataService, $q) {
   
    $scope.init=function()
    {
        console.log("quote", $scope.obj);
        // $scope.approvalStatus = $scope.params.approveStatus;
    }

    $scope.$watch('obj.Id',function(newVal) {
        if (newVal) {
            $scope.getQuoteDetails();
        }
    });

    $scope.getQuoteDetails = function() {
        var query = "Select Products__c, Status, ftr_IsBundle__c FROM Quote WHERE Id = '"+$scope.obj.Id+"'";
        
        $scope.makeQuery(query).then(function(records){
            $scope.record = records[0];
            console.log($scope.record);
            console.log($scope.data);
            console.log($scope.item);
            angular.forEach($scope.data.actions, function(action) {
                action.show = $scope.evaluateShow(action);
                console.log(action.%vlocity_namespace%__DisplayLabel__c, action.show);
            });
        }, function(error){
             
        });
    }

    $scope.evaluateShow = function(action) {
        if (action.%vlocity_namespace%__Filter__c && action.%vlocity_namespace%__Filter__c.includes('Products__c')) {
            let products = action.%vlocity_namespace%__Filter__c.split('INCLUDES')[1];
            products = products.substring(
                products.lastIndexOf("(") + 1, 
                products.lastIndexOf(")")
            );
            products = products.replaceAll("'", '').split(',');
            let productsOnQuote = $scope.record.Products__c || [];
            let includesProduct = products.some(r=> productsOnQuote.includes(r));
            if (action.%vlocity_namespace%__Filter__c.includes('ftr_IsBundle__c')) {
                let isBundle = action.%vlocity_namespace%__Filter__c.split('ftr_IsBundle__c').pop().toLowerCase();
                if (isBundle.includes('true')) {
                    isBundle = true;
                } else {
                    isBundle = false;
                }
                return includesProduct && (isBundle == $scope.record.ftr_IsBundle__c);
            } else {
                return includesProduct;
            }
        } else {
            return true;
        }
    }
    
    $scope.makeQuery = function(query) {
        var deferred = $q.defer();
        
        dataService.getRecords(query).then(function(records) {
            deferred.resolve(records);
        }, function(err) {
            deferred.reject(err);
        })

        return deferred.promise;
    }

    

}]);