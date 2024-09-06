vlocity.cardframework.registerModule.controller('newContactController', ['$scope', '$rootScope','$timeout','$q','bpService', function($scope, $rootScope,$timeout,$q,bpService) {

    $scope.record = {};
    $scope.displaySucessMessage=false;
    $scope.consoleLog = function(control) {
        console.log(control, $scope.record);
    }

    $scope.saveRecord = function(control) {
        let errors = [];
        angular.forEach(angular.element('#contact-form')[0].elements, (ele) => {
            console.log(ele);
            if (ele.nodeName == 'INPUT' && ele.required && (ele.value == null || ele.value == '')) {
                errors.push(ele.name);
            }
        });
        if (errors.length > 0) {
            let error = [...new Set(errors)];
            let reqMessage = error.length == 1 ? ' is required.' : ' are required.';
            $scope.errors = error.join(', ').replace(/, ([^,]*)$/, ', and $1') + reqMessage;
            return;
        }
        
        var configObj = {
            sClassName: '%vlocity_namespace%.IntegrationProcedureService',
            sMethodName: 'Contact_InsertNew',
            input: angular.toJson({ AccountId: $scope.getElementValue(control.propSetMap.AccountId), Contact: $scope.record  }),
            options: angular.toJson({})
        };
        executeRemoteAction(configObj).then(function(result){
            console.log
            $scope.clearRecord(control);
            if (result.Contacts){
                $scope.displaySucessMessage=true;
                setElementValue(control.propSetMap.Contacts, result.Contacts);
                $timeout(function () {
                    $scope.displaySucessMessage=false;
                }, 5000);   
            }
        })
    }

    $scope.clearRecord = function(control) {
        control.response = false;
        $scope.record = {};
        $scope.errors = null;
    }

    function executeRemoteAction(configObj) {
        $rootScope.loading = true;
        return $q(function(resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(function(result) {
                var remoteResp = angular.fromJson(result);
                console.log(configObj.sMethodName + ' result:', remoteResp);
                if(remoteResp && remoteResp.IPResult && remoteResp.error == 'OK') {
                    remoteResp = remoteResp.IPResult;
                    // if the VIP is still in pregress... call again
                    if (remoteResp.hasOwnProperty('vlcIPData') && remoteResp.hasOwnProperty('vlcStatus') && remoteResp.vlcStatus === 'InProgress') {
                        $rootScope.loading = true;
                        // overwriting as object in order to use same prop, but also have different display conditions
                        $rootScope.loadingMessage = {actionMessage: remoteResp.vlcMessage};
                        configObj.options = angular.toJson(remoteResp);
                        configObj.input = '{}';
                        return executeRemoteAction(configObj);
                    } else {
                        $rootScope.loading = false;
                        if (remoteResp.result && remoteResp.result.errorsAsJson && remoteResp.result.errorsAsJson.DRError) {
                            alert(remoteResp.result.errorsAsJson.DRError);
                            reject(remoteResp); 
                        } else {
                            resolve(remoteResp);   
                        }
                        
                    }
                } else if (remoteResp && remoteResp.OBDRresp && remoteResp.error == 'OK'){
                    $rootScope.loading = false;
                    remoteResp = remoteResp.OBDRresp;
                    resolve(remoteResp);
                } else {
                    console.error('Error in calling ' + configObj.sMethodName, remoteResp);
                    if (remoteResp.error)
                        alert(remoteResp.error);
                    $rootScope.loading = false;
                    reject(remoteResp);
                }
            }).catch(function (error) {
                console.error('Error while calling ' + configObj.sMethodName, error);
                alert(JSON.stringify(error));
                $rootScope.loading = false;
                reject(error);
            });
        });
    }

    $scope.onlyAllowNumbers = function(element) {    
        var value = $(element).val();
        var regExp = "^\\d+$";
        if (value.match(regExp)) {
            $(element).val(null)
        }
    }

    function setElementValue (name, value) {
        var toSet = value;
        // Accept either colons or periods as path seperators
        let namePath = name.split(/[:\.]/);

        for (var i = namePath.length - 1; i >= 0; i--) {
            var newSet = {};
            newSet[namePath[i]] = toSet;
            toSet = newSet;
        }

        baseCtrl.prototype.$scope.applyCallResp(toSet);
    }

}]);