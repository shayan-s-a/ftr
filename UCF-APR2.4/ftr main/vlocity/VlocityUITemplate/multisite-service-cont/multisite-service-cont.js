vlocity.cardframework.registerModule.controller('MainCtrl', ['$scope', '$rootScope', function ($scope, $rootScope) {
  // console.log('Records', $scope.records)
  $scope.orderByField = 'ProductDetails.ProductName';
  $scope.reverseSort = false;

  $scope.assets = ($scope.records.Asset)

  $scope.expandSelected = function (asset) {
    $scope.assets.forEach(function (val) {
      val.expanded = false;
    })
    asset.expanded = true;
  }

  $scope.expandChildren = function (assetChildren) {
    assetChildren.forEach(function (child) {
      child.expanded = true
    })
  }




  let assets = $scope.assets
  assets.forEach(p => {
    p.child = assets.filter(c => {
      let lastIndex = c.LineNumber.lastIndexOf('.');
      let level = lastIndex > 0 ? c.LineNumber.substr(0, lastIndex) : '';
      return p.LineNumber == level;
    });
  })
  $scope.assets = assets.filter(a => a.LineNumber.lastIndexOf('.') < 0);

  /**This is sorting based on child length */
  $scope.assets.sort(function (a, b) {
    return a.child.length - b.child.length;
  });

  // assets.forEach( asset => {
  //       let attributes = asset.ProductDetails.attributes
  //       if(attributes) {
  //           attributes.forEach( a => {
  //               p.child = assets.filter( c => {
  //                   let lastIndex = c.LineNumber.lastIndexOf('.');
  //                   let level = lastIndex > 0 ? c.LineNumber.substr(0,lastIndex): '';
  //                   return  p.LineNumber == level;
  //               });
  //           })
  //           acc.Asset = assets.filter( a => a.LineNumber.lastIndexOf('.') < 0);

  //           /**This is sorting based on child length */
  //           acc.Asset.sort(function(a, b) {
  //               return a.child.length - b.child.length;
  //           });
  //       }
  //   });



  // $rootScope.searchQuery = "";

  // console.log('Assets', $scope.assets)

}]);