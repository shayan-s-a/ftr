/* Please use vlocity.cardframework.registerModule to register your Angular Controller i.e. vlocity.cardframework.registerModule.controller('TestController', ['$scope', function($scope) { ... }]); */

vlocity.cardframework.registerModule.controller('CPQProductListCategoriesController', ['$scope', function($scope) { 
        
        $scope.$on('vlocity.cpq.category', function(event, data){
            var params = {};
            params.category = data.catalogId;                
            $scope.reloadProductList(params);    
        });
        
        $scope.reloadProductList = function(params) {
            if ($scope.isLoaded) {
			    // Update the Data source with the latest catalog Id filter
  	            $scope.$parent.$parent.updateDatasource(params);
            } 
        }

    }
]);