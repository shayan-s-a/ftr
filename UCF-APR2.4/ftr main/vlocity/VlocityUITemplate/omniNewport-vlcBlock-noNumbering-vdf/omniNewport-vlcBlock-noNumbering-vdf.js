vlocity.cardframework.registerModule.controller('vlcBlockController', [
    '$scope', '$http',
    function($scope, $http) {
        $scope.mapObject = {
            'templateMapping': {
                'input': 'InputTemplate.tpl.html',
                'select': 'vdf-select-template',
                'checkbox': 'vdf-checkbox-template'
            }
        };

        const mapType = (type) => {
            switch (type) {
                case 'Picklist':
                    return 'select';
                case 'Text':
                    return 'text';
                case 'Checkbox':
                    return 'checkbox';
                case 'Number':
                    return 'number';
                default:
                    return '';
            }
        }

        const mapValues = (values) => {
            return values.map(value => ({
                label: value.displayText,
                ...value
            }));
        }

        const formatAttributes = (SpeedinMbps,noofpartners,items, ProductName,ProductCode, Id, ServiceAccountId) => {
            const formattedAttributes = [];
            let partnered = false;
            console.log('initial partner value ',partnered);
            console.log('SpeedinMbps in products temp',SpeedinMbps);
            //const partneredvalue = false;
           // let partnered ;
            if (items && items.FTR_ENT_ELIG_ATTCAT) {                    
                    items.FTR_ENT_ELIG_ATTCAT.map(data => {if(data.attributeuniquecode__c == 'ATTR_ELIGBL_PARTNRD'){
                        
                         partnered = data.attributeRunTimeInfo.value;
                        console.log('partnered',partnered);
                       
                         
                    }});
                } 
                if (items && items.FTR_ENT_TECH_ATTCAT) {
                    const newAttributes = [];
                    items.FTR_ENT_TECH_ATTCAT.map(data => {
                        if(data.attributeuniquecode__c != 'ATTR_ENTER_DOMAIN_ID' && data.attributeuniquecode__c != 'ATTR_NSG_TYPE' && data.attributeuniquecode__c != 'ATTR_TECH_JURISDICTION' 
                        && data.attributeuniquecode__c != 'ATTR_MANAGED_FIREWALL' && data.attributeuniquecode__c != 'ATTR_INSTALL_KIT' && data.attributeuniquecode__c != 'ATTR_ROUTER_MODEL'
                        && data.attributeuniquecode__c != 'ATTR_PRJID' && data.attributeuniquecode__c != 'ATTR_MNGD_ DEVICE_TYPE'  && data.attributeuniquecode__c != 'ATTR_WaitSemaphore'
                        && data.attributeuniquecode__c != 'ATTR_OVC_VLAN'&& data.attributeuniquecode__c != 'ATTR_FIRSTELAN'){
                             //items.FTR_ENT_TECH_ATTCAT.delete(data);
                            
                            newAttributes.push(data);
                             
                        }
                        console.log('partnered to add',partnered);
                         if(noofpartners > 0 && data.attributeuniquecode__c == 'ATTR_OVC_VLAN'){
                             newAttributes.push(data);
                         } 
                    });
                            

                
                    const attributes = newAttributes.map(data => {
                         
                        const {
                            attributeRunTimeInfo: { value, values, dataType, selectedItem },
                            attributedisplayname__c,
                            attributeuniquecode__c,
                            valuedescription__c,
                            isrequired__c,
                            isreadonly__c,
                            value: defaultValue
                        } = data;
                       
                        return {
                            label: attributedisplayname__c,
                            description: valuedescription__c,
                            values: values ? mapValues(values) : null,
                            type: mapType(dataType),
                            value: value || selectedItem && selectedItem.value,
                            code: attributeuniquecode__c,
                            required: isrequired__c,
                            disabled: isreadonly__c
                        } 
                        
                    })
                    formattedAttributes.push({
                        ProductName,
                        ProductCode,
                        Attributes: attributes.sort((a, b) => a.DisplaySequence - b.DisplaySequence),
                        Id,
                        ServiceAccountId,
                        noofpartners,
                        SpeedinMbps
                    });
                }
            //console.log(JSON.stringify(formattedAttributes));
            return formattedAttributes;
        };
        
        $scope.bpTree.response.OrderItems = [];

        $scope.$watchCollection('bpTree.response.Products.AccessLocation', function(newValue,oldValue) {
            if (!newValue) return;
            $scope.items = [];
            // $scope.bpTree.response.OrderItems = [];
            const { Products: { AccessLocation: orderItems } } = $scope.bpTree.response;
            
            // TODO: Remove once a better solution is found;
            $scope.locationId = $scope.$parent.$parent.control.response.Access_ServiceAccountId;
            
            if (orderItems.length > 0) {
                orderItems.forEach(orderItem => {
                    const {
                        SpeedinMbps,
                        noofpartners,
                        Location,
                        ServiceAccountId,
                        ProductCode,                       
                        Product: {
                            ProductName,
                            json = {}  
                        },
                        Id
                    } = orderItem;
                    // Only add items for this location
                    if (ServiceAccountId !== $scope.locationId) {
                        return;
                    }
                    
                    if (json) {
                        console.log('json->'+JSON.stringify(json));
                        const formatted = formatAttributes(SpeedinMbps,noofpartners,json, ProductName,ProductCode, Id, ServiceAccountId);
                        console.log(JSON.stringify(formatted));
                        if (formatted.length > 0) {
                            $scope.bpTree.response.OrderItems.push(...formatted);
                        }
                    }
                })
                $scope.loaded = true;
            }
        })
        $scope.bpTree.response.selectedUNIs = [];
        $scope.selectedUNI = function(item){
            if(item.selected){
                $scope.bpTree.response.selectedUNIs.push(item);
            }else{
                var currentItemIndex =$scope.bpTree.response.selectedUNIs.findIndex(x => x.Id == item.Id);
                if(currentItemIndex > -1){
                    $scope.bpTree.response.selectedUNIs.splice(currentItemIndex,1);
                }
            }
            
        }
}]);