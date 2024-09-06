vlocity.cardframework.registerModule.controller('ProductListController', ['$scope','$rootScope','bpService', function ($scope, $rootScope, bpService) {

  $scope.selectedItem = { };
  $scope.isFirstAdd = true;
  $scope.disableAddProductButton = false;
  $scope.bpTree.response.ConfiguredOptions = [];
 // $scope.bundleType = $scope.bpTree.response.BuildYourProduct.BundleType;
 
  $scope.sort = {
    column: '',
    descending: false
  };    

  $scope.sortColumn = function(column) {

      var sort = $scope.sort;

      if (sort.column == column) {
          sort.descending = !sort.descending;
      } else {
          sort.column = column;
          sort.descending = false;
      }
  };
      
  $scope.selectedCls = function(column) {
        return column == $scope.sort.column && 'sort-' + $scope.sort.descending;
  };

  $scope.optionChanged = function(item, index) {
    console.log('Selected:', JSON.parse(item));
    $scope.bpTree.response.CurrentProduct = JSON.parse(item);
    $scope.bpTree.response.CurrentProduct.ServiceAccountId = $scope.bpTree.response.CurrentLocation.Id;
    $scope.selectedItem.row = index;
  };

}])