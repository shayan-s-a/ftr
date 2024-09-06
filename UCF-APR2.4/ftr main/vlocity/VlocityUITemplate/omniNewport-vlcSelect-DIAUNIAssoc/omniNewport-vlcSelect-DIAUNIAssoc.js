vlocity.cardframework.registerModule.controller('DIAUNISelectController', ['$scope','$timeout','$q','ouiBaseService', function($scope, $timeout, $q, ouiBaseService) {

    $scope.UNIList = [];
    $scope.elementType = $scope.child.eleArray[0].name.includes('Spoke') ? 'SpokeId' : 'DIAHubId';
    $scope.track = {};
    $scope.valuesToRetrieve = [
        {
            property: 'UNILocationId',
            label: 'UNILocationId'
        },
        {
            property: 'UNILocationName',
            label: 'UNILocationName'
        },
        {
            property: 'DIALocationDetail',
            label: 'DIALocationDetail'
        },
        {
            property: 'rootBundle',
            label: 'DIABundle'
        },
        {
            property: 'DIAId',
            label: 'DIAId'
        },
    ];
    $scope.EVCLocation;
    $scope.rootBundle;

    $scope.$watch('bpTree.response.UNI', function(newVal,oldVal) {
        if (newVal != null) {
            $timeout(function() {
                $scope.siblingElements = $scope.$parent.$parent.$parent.children;
                $scope.getUNIs();
                if (Array.isArray($scope.bpTree.response.UNI))
                    getExistingUNIs();
                else {
                    if ($scope.UNIList[0] != null) {
                        $scope.itemSelected($scope.UNIList[0], true);
                    }
                }  
            });
        }
    });

    function getExistingUNIs() {
        // call DR
        // it will return UNIId, iterate 
        var searchParams = {
            "DRParams": { "EVCId": $scope.DIAId },
            "Bundle": "UNIHostRemoteExtract"
        };
        return $q(function (resolve, reject) {
            ouiBaseService.GenericInvoke(
                "%vlocity_namespace%.DefaultDROmniScriptIntegration",
                "invokeOutboundDR",
                JSON.stringify(searchParams),
                JSON.stringify({ "useQueueableApexRemoting": false } )
            )
            .then(function(data){
                var result = JSON.parse(data);
                var uniIndex;
                // result = {"OBDRresp":{"OrderItem":{"SpokeId":"8021h000000tBwdAAE","HubId":"8021h000000tBwdAAE"}},"error":"OK"}
                if (result.OBDRresp != null && result.OBDRresp.OrderItem != null) {
                    var uniId = result.OBDRresp.OrderItem.HubId;
                    angular.forEach($scope.UNIList, function(uni, index) {
                        if (uni.value == uniId) {
                            uniIndex = index;
                        }
                    });
                }
                if (uniIndex != null)
                    $scope.itemSelected($scope.UNIList[uniIndex], true);
                else 
                    $scope.itemSelected($scope.UNIList[0], true);
            })
            .catch(function(err) {
                console.error('error while retrieving UNIs', err);
                reject(err);
            })
        });
    };

    function findElement(property, label) {
        for (let i=0; i< $scope.siblingElements.length; i++) {
            let value = $scope.siblingElements[i];
            if (value.eleArray[0].name == label) {
                $scope[property] = value.eleArray[0].response;
                $scope.$apply();
            }
        }
    };

    function setElement(response, label) {
        for (let i=0; i< $scope.siblingElements.length; i++) {
            let value = $scope.siblingElements[i];
            if (value.eleArray[0].name == label) {
                console.debug('applying response', response, label);
                value.eleArray[0].response = response;
                // $scope.$apply();
            }
        }
    };

    $scope.getUNIs = function () {
        angular.forEach($scope.valuesToRetrieve, function(value) {
            findElement(value.property, value.label);
        });
        // clear uni list
        $scope.UNIList = [];
        // if its an array, iterate, else, set
        if (Array.isArray($scope.bpTree.response.UNI)) {
            angular.forEach($scope.bpTree.response.UNI, function(value, key) {
                if (value.ServiceAccountId == $scope.UNILocationId) {
                    $scope.UNIList.push({
                        'name': 'UNI ' + value.UNIHostName,
                        'value': value.UNIHostId
                    });
                }
            });
        } else {
            if ($scope.bpTree.response.UNI.ServiceAccountId == $scope.UNILocationId) {
                $scope.UNIList.push({
                    'name': 'UNI ' + $scope.bpTree.response.UNI.UNIHostName,
                    'value': $scope.bpTree.response.UNI.UNIHostId
                });
            }
        }
    };

    $scope.itemSelected = function(item, onInit) {
        $scope.child.eleArray[0].response = item;
        $scope.track.selectedValue = item;
        if ($scope.elementType.includes('Spoke') && $scope.rootBundle.includes('DIA'))
            return;
        setElement(item.value, $scope.elementType);
        if (!onInit){
            console.debug(item);
        }
    };

    $scope.uniqueArrayOf = function (collection, keyname) {
        var output = [], 
        keys = [];

        angular.forEach(collection, function(item) {
            var key = item[keyname];
            if(keys.indexOf(key) === -1) {
                keys.push(key);
                output.push(item);
            }
        });
        return output;
   };
}]);