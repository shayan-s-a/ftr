vlocity.cardframework.registerModule.controller('customActionController', [
  '$scope', '$rootScope', '$log', '$timeout', '$sldsModal', 'dataSourceService',
  function($scope, $rootScope, $log, $timeout, $sldsModal, dataSourceService) {
    $scope.doNotShowServiceAcclst = [
        'ENT_ETH_IP_0002',
        'ENT_ETH_MR_001',
        'ENT_ETH_ADV_01',
        'ENT_ETH_CELL_01',
        'ENT_ETH_STD_01',
        'ENT_ETH_WIFI_01',
        'ENT_ETH_WIFI_02'
    ];
    $scope.chilReadOnly = [
        'ENT_ETH_ADV_01',
        'ENT_ETH_STD_01',
        'ENT_ETH_CELL_01'
    ];

    /**
     * Gets current attributes for item, and update the record on the page
     * 
     * @param {string} itemId Id of order item
     * @param {Array<Object>} records page object containing attribute data for order item
     */
    const getAttributes = (itemId, records) => {
      const datasource = {
        type: 'ApexRemote',
        value: {
          remoteClass: 'ftr_CpqService',
          remoteMethod: 'getXLIAttributes',
          inputMap: {
            "itemId": itemId
          },
          apexRemoteResultVar: 'result.records'
        }
      };
      dataSourceService.getData(datasource, $scope, null).then(
        function(data) {
            const { attributes } = data;
            if (!attributes) {
              return;
            }

            records.forEach(product => {
              if (!product.productAttributes.records) {
                return;
              }
              product.productAttributes.records.forEach(attribute =>{
                const newValue = attributes[attribute.code];
                if (newValue !== undefined) {
                  attribute.userValues = newValue;
                }
              })
            })
        }, function(error) {
            $log.error(error);
        });
    }

    /**
     * Update page object
     * 
     * @param childProd Represent an order item formatted for VDF
     */
    $scope.getUpdatedObject = (childProd) => {
        const {
          Id: { value: itemId },
          attributeCategories: { records } = {}
        } = childProd;
        
        getAttributes(itemId, records);
    }

    $scope.split = function(obj){
         
        var lineItemName = obj.Name;
        var lineItemId = obj.Id.value;
        console.log("Splitting Line Item '" + lineItemName + "' with Id = " + lineItemId);
         
        // Launch the OmniScript
        window.open("/apex/%vlocity_namespace%__OmniScriptUniversalPage?id=" + lineItemId + "&layout=lightning#/OmniScriptType/CPQ/OmniScriptSubType/SplitLineItemByServiceAccount/OmniScriptLang/English/ContextId/" + lineItemId + "/PrefillDataRaptorBundle//true", "_self");
    };
}]);