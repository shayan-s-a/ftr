vlocity.cardframework.registerModule.controller('dsatInfoDetailsController', ['$scope', '$route', function ($scope, $route) {
    $scope.dsatInfo = $scope.bpTree.response.DSATAddressValidationSuccessResponse;
    $scope.errorMessage = 'show some error here';
    $scope.createdbyuser = $scope.bpTree.response.DSATAddressValidationSuccessResponse.CreatedBy;
    //console.log('dsatinfo',dsatInfo);
	//$scope.partnerList = $scope.bpTree.response.DSATAddressValidationSuccessResponse.EReachProviders;
    $scope.partnerList = [];
    $scope.partnerList = $scope.bpTree.response.DSATAddressValidationSuccessResponse.vendorlist;

    


    // $scope.HBEProductList = [];
    // $scope.HBEProductList = $scope.bpTree.response.DSATAddressValidationSuccessResponse.Products;
    /*$scope.getPartnerInfo = function(){
        $scope.partnerList = [];
        $scope.partnerList = $scope.bpTree.response.DSATAddressValidationSuccessResponse.vendorlist;
        /*angular.forEach(partners, function (partnerData) {
            var prodlist = partnerData.Products;
            var concatProdlist;
            if(prodlist.length > 0){
                angular.forEach(prodlist, function (prodData) {
                    if(concatProdlist != undefined){
                        concatProdlist = concatProdlist+','+prodData;
                    }else{
                        concatProdlist = prodData;
                    }
                })
            }
            partnerData.prodList = concatProdlist;
            if(partnerData.ProviderName == 'Level3' || partnerData.ProviderName == 'Century Link'){
                partnerData.ProviderName = 'Lumen';
            }
            if(partnerData.ProviderName == 'ATT'){
                partnerData.ProviderName = 'AT&T';
            }
            $scope.partnerList.push(partnerData);
        })
        

    }*/
}])