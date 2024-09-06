vlocity.cardframework.registerModule.controller('CPQCategoriesListController', ['$scope','$rootScope', 'dataService','$q', function($scope, $rootScope, dataService, $q) {
    
    // Query Root Catalog Id

    // console.log('cpq-base-grid-categories scope: ', $scope);
    // console.log('cpq-base-grid-categories rootScope: ', $rootScope);
    
    $scope.getRootCatalogId = function() {
        var query = "Select Id FROM %vlocity_namespace%__Catalog__c WHERE Name = 'Root'";
        
        $scope.makeQuery(query).then(function(records){
            $scope.isRootCatalogIdFetched = true;
            $rootScope.rootCatalogId = records[0].Id;
        }, function(error){
             
        });
    }

    $scope.getQuoteDetail = function() {
        if ($rootScope.cartId == null) return;
        var query = "Select ftr_IsBundle__c FROM Quote WHERE Id = '"+$rootScope.cartId+"'";
        
        $scope.makeQuery(query).then(function(records){
            $scope.isRootCatalogIdFetched = true;
            $scope.isBundled = records[0].ftr_IsBundle__c;
        }, function(error){
             
        });
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
    
    $scope.getQuoteDetail();
    $scope.getRootCatalogId();
    
    $scope.addAllCategory = function(records) {
        var allRecord = {
            'catalogName': 'All',
            'catalogId': null
        }
        
        records.push(allRecord);
        $scope.reloadLayout2(records);
    }

    

}]);