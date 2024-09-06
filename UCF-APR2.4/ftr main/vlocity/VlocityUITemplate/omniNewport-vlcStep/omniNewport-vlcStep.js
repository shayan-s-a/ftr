vlocity.cardframework.registerModule.controller('vltNdsStepController', ['$scope', function ($scope) {
    
    $scope.navigateToCart = function () {
        window.location.href = '/apex/%vlocity_namespace%__hybridcpq?id=' + $scope.bpTree.response.ContextId;
    }

    $scope.hideModal = function () {
       $scope.modal.showModal = false;
    }

    $scope.showModal = function () {
       $scope.modal.showModal = true;
    }

    $scope.goNext = function (step) {
        console.log(step);
        if(stepIsValid(step)) {
            $scope.nextRepeater(step.nextIndex, step.indexInParent);
        }
    }

    function gotoStep (stepName) {
        for (let i=0;i<$scope.bpTree.children.length;i++) {
            if ($scope.bpTree.children[i].name == stepName) {
                $scope.sidebarNav($scope.bpTree.children[i]);
                return;
            }
        }
    }

    function stepIsValid (step) {
        $scope.modal = {
            title: 'Please fix the following errors',
            msgs: [],
            cancelLabel: 'Close',
            isError: true
        };

        if (step.name == 'DisplayServiceLocations') {
            if (!$scope.bpTree.response.hasOwnProperty('SelectedLocations') || $scope.bpTree.response.SelectedLocations.length == 0) {
                $scope.modal.msgs.push('Service location is required.');
            } else if ($scope.bpTree.response.SelectedLocations.length > 0) {
                for (let i=0; i < $scope.bpTree.response.SelectedLocations.length; i++) {
                    let location = $scope.bpTree.response.SelectedLocations[i];
                    if (location.Premises == null) {
                        $scope.modal.msgs.push(location.ShippingStreet + ' requires a DSAT refresh.');
                    } 
                }
            }

        } else if (step.name == 'QuoteCreation') {
            $scope.modal.msgs = getFieldErrors(step);
        }

        if ($scope.modal.msgs.length > 0) {
            $scope.showModal();
            return false;
        }
        
        return true;
    }

    function getFieldErrors(step) {
        var errors = [];
        // wont work for repeatable block
        for (let i = 0; i < step.children.length; i++) {
            if (step.children[i].eleArray[0].propSetMap.required && (step.children[i].response == null || step.children[i].response == ''))  {
                if (step.children[i].eleArray[0].propSetMap.label.includes('?'))
                    errors.push(step.children[i].eleArray[0].propSetMap.label)
                else
                    errors.push(step.children[i].eleArray[0].propSetMap.label + ' is required.')
            }
        }
        return errors;
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

    function getElementValue (name, cursor) {
        let namePath = name.split(/[:\.]/);
        let p;
        if (!cursor)
            cursor = $scope.bpTree.response;
        while (undefined !== (p = namePath.shift())) {
            if (p.startsWith('#')) {
                p = p.substr(1);
                let kv = p.split('=');
                let newCursor = undefined;
                for (let i = 0; i < cursor.length; i++) {
                    if (cursor[i][kv[0]] == kv[1]) {
                        newCursor = cursor[i];
                        break;
                    }
                }
                cursor = newCursor;
            } else {
                cursor = cursor[p];
            }
            if (cursor === undefined) {
                break;
            }
        }
        return cursor;
    }

}])