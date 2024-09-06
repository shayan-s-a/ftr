/* Please use vlocity.cardframework.registerModule to register your Angular Controller i.e. vlocity.cardframework.registerModule.controller('TestController', ['$scope', function($scope) { ... }]); */

vlocity.cardframework.registerModule.controller('CPQCategoryItemController', ['$scope', '$rootScope', function($scope, $rootScope) { 

        $scope.selectCategory = function(category) {
            $rootScope.$broadcast('vlocity.cpq.category', category);
        };
        
        $scope.$on('vlocity.cpq.category', function(event, data){
            if (data) {
                $scope.checkSelectedCategory(data);
            }

        });
        
        $scope.checkSelectedCategory = function(selectedCategory) {
            $scope.isSelectedCategory = selectedCategory.catalogId === $scope.obj.catalogId;
        }
    }
]);