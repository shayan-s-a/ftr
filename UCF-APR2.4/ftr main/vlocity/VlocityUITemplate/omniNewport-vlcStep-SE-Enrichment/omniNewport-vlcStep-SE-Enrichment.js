vlocity.cardframework.registerModule.controller('vltNdsStepController', ['$scope', function ($scope) {

    const bpPaths = {
        orderItems : 'OrderItems'
    };
    
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

        if (step.name == 'ReviewAttributes') {
            var lst = validateAttributes();
            if (lst.length > 0) {
                $scope.modal.msgs = $scope.modal.msgs.concat(lst);
            }
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

    function validateAttributes() {
        var messages = [];
        var orderItems = getElementValue(bpPaths.orderItems);
        for (let item of orderItems) {
            console.log(item);
            if (item.ProductCode == 'ENT_ETH_UNI_0001') {
                let portSpeed = getAttributeValue('ATTR_PORT_SPEED', item);
                let physicalMedium = getAttributeValue('ATTR_PHY_MEDIUM', item);
                 let ovcvlan = getAttributeValue('ATTR_OVC_VLAN', item);
                console.log(item.SpeedinMbps);
                console.log(item.ProductName);
                  console.log(portSpeed);
                if(item.SpeedinMbps==12345678){
                    break;
                }else{
                    if(item.SpeedinMbps <= 1000 && portSpeed != '1G' ){
                        messages.push(portSpeed +' is not available. please select a different port speed');
                        }
                        if(item.SpeedinMbps > 1000 && item.SpeedinMbps <= 10000 && portSpeed != '10 GBPS' ){
                            messages.push( portSpeed +' is not available. please select a different port speed');
                        }
                        if(item.SpeedinMbps > 10000 && item.SpeedinMbps <= 100000 && portSpeed != '100 GBPS' ){
                            messages.push(portSpeed +' is not available. please select a different port speed');
                        }
                }
               
                 if (ovcvlan != null && item.noofpartners>0){
                     if( isNaN(ovcvlan) == true){
                        messages.push('OVC VLAN field should have Numeric Value');  
                     }
                     if(ovcvlan.length != 4){
                        messages.push('OVC VLAN field should have 4 digit number'); 
                     }

                 }else{
                     if(item.noofpartners>0){
                        messages.push('Please Select OVC VLAN'); 
                     }

                 }

                if (physicalMedium == null){
                    messages.push('Please Select Physical Medium');
                }
                 if (portSpeed == null ){
                    messages.push('Please Select Port Speed');
                }

                if (portSpeed == '10 GBPS' && physicalMedium == 'Copper RJ45') {
                    messages.push('10G port speed cannot use Copper RJ45.');
                }

                /*if (portSpeed == '100 GBPS') {
                    messages.push('100 GBPS is not available, please select a different port speed option');
                }   */ 

                // To Uncommect after M6 and Provisioning starts supporting 100G port speed
                if (portSpeed == '100 GBPS' && physicalMedium == 'Copper RJ45') {                             
                    messages.push('100G port speed cannot use Copper RJ45');                                
                    messages.push('Use Fiber Single Mode 1310nm 100 Gbps or Fiber Multi Mode 850nm 100 Gbps');  
                }

                if (portSpeed == '10 GBPS' && physicalMedium == '1310 SMF for 100Gbps port') {
                    messages.push('10G port speed cannot use 1310 SMF for 100Gbps port');
                    messages.push('Use Fiber Single Mode 1310nm or Fiber Multi Mode 850nm');
                }

                if (portSpeed == '10 GBPS' && physicalMedium == '850 MMF for 100Gbps port') {
                    messages.push('10G port speed cannot use 850 MMF for 100Gbps port');
                    messages.push('Use Fiber Single Mode 1310nm or Fiber Multi Mode 850nm');
                }

                // To Uncommect after M6 and Provisioning starts supporting 100G port speed
                if (portSpeed == '100 GBPS' && physicalMedium == 'Fiber Single Mode 1310nm') {
                    messages.push('100G port speed cannot use Fiber Single Mode 1310nm');               
                    messages.push('Use 1310 SMF for 100Gbps port or 850 MMF for 100Gbps port');         
                }

                // To Uncommect after M6 and Provisioning starts supporting 100G port speed
                if (portSpeed == '100 GBPS' && physicalMedium == 'Fiber Multi Mode 850nm') {
                    messages.push('100G port speed cannot use Fiber Multi Mode 850nm');               
                    messages.push('Use 1310 SMF for 100Gbps port or 850 MMF for 100Gbps port');           
                }

                if (portSpeed == '1G' && physicalMedium == '1310 SMF for 100Gbps port') {
                    messages.push('1G port speed cannot use 1310 SMF for 100Gbps port');
                    messages.push('Use Copper RJ45, Fiber Single Mode 1310nm or Fiber Multi Mode 850nm');
                }

                if (portSpeed == '1G' && physicalMedium == '850 MMF for 100Gbps port') {
                    messages.push('1G port speed cannot use 850 MMF for 100Gbps port');
                    messages.push('Use Copper RJ45, Fiber Single Mode 1310nm or Fiber Multi Mode 850nm');
                }
   
            }
        }
        return [...new Set(messages)];;
    }

    function getAttributeValue(code, item) {
        var val;
        for (let i of item.Attributes) {
            if (i.code == code) {
                val = i.value;
                console.log('value',i.value);
                break;
            }
        }
        return val;
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