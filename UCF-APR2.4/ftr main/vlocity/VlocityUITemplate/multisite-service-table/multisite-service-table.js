vlocity.cardframework.registerModule.controller('MainCtrl', ['$scope', 'dataSourceService', '$filter', '$rootScope', function ($scope, dataSourceService, $filter, $rootScope) {
  // group child assets with parent (bundle = parent, all product/s = child)
  console.log('data: ', $scope.records)
  $scope.assetSyncInProgress = false;

  $scope.dpiList = [];
  $scope.dsatList = [];
  $scope.m6List = [];

  /** Get JSON object with category wise attributes : start 
   * @author kalyan
   */
    const categoryJSONDataSource = {
      type: 'ApexRemote',
      value: {
        remoteClass: 'AssetsUIContoller',
        remoteMethod: 'getAssetUIMappingJSON',
        inputMap: {}
      }
    };

    dataSourceService.getData(categoryJSONDataSource, $scope, null).then(
      function (data) {
        if(data && data.ResultJSON) {
          $scope.categoryData = JSON.parse(data.ResultJSON);
          $scope.processAttributeCategories();
        }
    }, function (error) {
          console.log('getCategoryJSON error');
    });
  
    /** Get JSON object with category wise attributes : start  */

  $scope.criteria = {
    searchtext: '',
    sort: 'Name',
    desc: false,
    currentPage: 0,
    pageSize: 10
  };

  $scope.allowActions = $scope.records.AccountRecordType == 'Master';
  $scope.assets = [];


    /** Function to split attributes into categories : start 
    * @author kalyan
    */

  $scope.processAttributeCategories = function(){

    if($scope.categoryData) {
      $scope.dpiList = Object.keys($scope.categoryData.DPI);
      $scope.dsatList = Object.keys($scope.categoryData.DSAT);
      $scope.m6List = Object.keys($scope.categoryData.M6);
    }

    if ($scope.records.Asset) {
      let ungroupedAssets = Array.isArray($scope.records.Asset) ? $scope.records.Asset : [$scope.records.Asset]
      ungroupedAssets = ungroupedAssets.filter(a => (a.LineNumber && a.ProductCode));
      let productsToRemove = [];
      // set UNI line numbers so they group with their respective EVC
      ungroupedAssets.forEach(p => {
        ungroupedAssets.forEach(u => {
          if (p.UNIHost == u.Id || p.UNIRemote == u.Id) {
            u.LineNumber = p.LineNumber + '.001';
          }
        })
      })
      ungroupedAssets.forEach(p => {
        p.child = ungroupedAssets.filter(c => {
          let lineNumbers = c.LineNumber.split('.');
          let level = lineNumbers[1] ? lineNumbers[0] : '';
          let isChild = p.LineNumber == level;
          if (isChild) {
            productsToRemove.push(c.Id)
          }
          return isChild
        })
        /** Add attributes to child level products : start */
        if(p && p.child && Array.isArray(p.child) && p.child.length > 0 && typeof(p.child[0]) === 'object') {
          const obj = p.child[0].Attributes;
          p.child[0].dpiAttributes = [];
          p.child[0].dsatAttributes = [];
          p.child[0].m6Attributes = [];
          if (obj) {
            $scope.dpiList.forEach(key =>{
              if(obj.hasOwnProperty(key)) {
                p.child[0].dpiAttributes.push({value: obj[key], ...$scope.categoryData.DPI[key] });
              } else {
                p.child[0].dpiAttributes.push({value: null, ...$scope.categoryData.DPI[key] });
              }
            });
    
            $scope.dsatList.forEach(key =>{
              if(obj.hasOwnProperty(key)) {
                p.child[0].dsatAttributes.push({value: obj[key], ...$scope.categoryData.DSAT[key] });
              } else {
                p.child[0].dsatAttributes.push({value: obj[key], ...$scope.categoryData.DSAT[key] });
              }
            });
    
            $scope.m6List.forEach(key =>{
              if(obj.hasOwnProperty(key)) {
                p.child[0].m6Attributes.push({value: obj[key], ...$scope.categoryData.M6[key] });
              } else {
                p.child[0].m6Attributes.push({value: null, ...$scope.categoryData.M6[key] });
              }
            });
          }
  
        }
        /** Add attributes to child level products : end */
        p.assetChecked = false;
      })
  
      $scope.assets = ungroupedAssets.filter(a => !productsToRemove.includes(a.Id)).slice(0, 10)
  
      /** Add attributes to parent level products : start */
      $scope.records.Asset.forEach(obj => {
        if(obj) {
          obj.dpiAttributes = [];
          obj.dsatAttributes = [];
          obj.m6Attributes = [];
          const attributes = obj.Attributes;
          $scope.dpiList.forEach(key =>{
            if(attributes && attributes.hasOwnProperty(key)) {
              obj.dpiAttributes.push({value: attributes[key], ...$scope.categoryData.DPI[key] });
            } else {
              obj.dpiAttributes.push({value: null, ...$scope.categoryData.DPI[key] });
            }
          });
    
          $scope.dsatList.forEach(key =>{
            if(attributes && attributes.hasOwnProperty(key)) {
              obj.dsatAttributes.push({value: attributes[key], ...$scope.categoryData.DSAT[key] });
            } else {
              obj.dsatAttributes.push({value: null, ...$scope.categoryData.DSAT[key] });
            }
          });
    
          $scope.m6List.forEach(key =>{
            if(attributes && attributes.hasOwnProperty(key)) {
              obj.m6Attributes.push({value: attributes[key], ...$scope.categoryData.M6[key] });
            } else {
              obj.m6Attributes.push({value: null, ...$scope.categoryData.M6[key] });
            }
          });
        }
      });
      /** Add attributes to parent level products : end */
    }
  }


  $scope.getAssets = function () {
    return $filter('filter')($scope.assets, $scope.criteria.searchtext)
  }

  $scope.numberOfPages = function () {
    return Math.ceil($scope.getAssets().length / $scope.criteria.pageSize);
  }

  $scope.$watch('criteria.searchtext', function (newValue, oldValue) {
    if (oldValue != newValue) {
      $scope.criteria.currentPage = 0;
    }
  }, true);

  $scope.sort = function (field) {
    if ($scope.criteria.sort == field) {
      $scope.criteria.desc = !$scope.criteria.desc;
    } else {
      $scope.criteria.sort = field;
      $scope.criteria.desc = false;
    }
  }

  $scope.selectedAssets = function () {
    return $scope.assets.filter(item => item.assetChecked == true);
  }

  $scope.allSelected = function () {
    return $scope.assets.every(item => item.assetChecked == true);
  }

  $scope.toggleSelection = function (item) {
    item.assetChecked = !item.assetChecked;
  }

  function getItem(itemId) {
    return $scope.assets.find(record => record.Id == itemId);
  }

  $scope.toggleAll = function () {
    if ($scope.allSelected()) {
      $scope.assets.forEach(i => {
        i.assetChecked = false
      })
    } else {
      $scope.assets.forEach(i => {
        i.assetChecked = true
      })
    }
  }

  $scope.changeToQuote = function () {
    let assetIdsSelected = getSelectedAssetIds();
    let term = getContractTerm();
    let changeToQuoteOSTargetUrl = '/apex/' + $rootScope.nsPrefix + 'OmniScriptUniversalPage?&layout=newport&id=' +
      $scope.params.id + ':all:' + assetIdsSelected + '&ServiceTerm=' + term +
      '#/OmniScriptType/MACD/OmniScriptSubType/ChangeToQuote/OmniScriptLang/English/ContextId/' + $scope.params.id + ':all:' + assetIdsSelected +
      '/PrefillDataRaptorBundle//true';
    $scope.launchUrl(changeToQuoteOSTargetUrl, 'Change to Quote');
  }

  // $scope.moveAsset = function () {
  //   let assetIdsSelected = getSelectedAssetIds();
  //   let moveOSTargetUrl = '/apex/' + $rootScope.nsPrefix + 'MoveInAccount?id=' + assetIdsSelected;
  //   $scope.launchUrl(moveOSTargetUrl, 'Move');
  // }

  // $scope.changeToOrder = function () {
  //   let assetIdsSelected = getSelectedAssetIds();
  //   let changeToOrderOSTargetUrl = '/apex/' + $rootScope.nsPrefix + 'MACDFdo?id=' + assetIdsSelected +
  //     '#/OmniScriptType/MACD/OmniScriptSubType/FDO/OmniScriptLang/English/ContextId/' + assetIdsSelected +
  //     '/PrefillDataRaptorBundle//true';
  //   $scope.launchUrl(changeToOrderOSTargetUrl, 'Change to Order');
  // }

  $scope.syncSelectedAssets = function() {
    let assetIdsSelected = getSelectedAssetIds().split('+');
    $scope.assetSyncInProgress = true;
    const datasource = {
      type: 'ApexRemote',
      value: {
        remoteClass: 'ftr_SyncAssetsWithM6AndDPI',
        remoteMethod: 'syncAssets',
        inputMap: {
          "assetIds": assetIdsSelected
        },
        apexRemoteResultVar: 'result.records'
      }
    };
    dataSourceService.getData(datasource, $scope, null).then(
      function (data) {
        console.log('syncSelectedAssets result', data);
        $scope.assetSyncInProgress = false;
        
        // need to refresh the data
      }, function (error) {
        console.error('syncSelectedAssets error', error);
        $scope.assetSyncInProgress = false;
      });
  }

  $scope.launchUrl = function (launchUrl, title) {
    if (typeof sforce !== 'undefined') {
      if (sforce.console && sforce.console.isInConsole()) {
        sforce.console.openPrimaryTab(null, launchUrl, true, title, null, title);
      } else {
        if (typeof sforce.one === 'object') {
          sforce.one.navigateToURL(launchUrl, false);
        } else {
          window.parent.location.href = launchUrl;
        }
      }
    } else {
      // I found out that sforce is always defined in all my testing, but to be defensive, we will also handle it for some reason not being there
      window.parent.location.href = launchUrl;
    }
  }

  function getSelectedAssetIds() {
    let lst = [];
    $scope.selectedAssets().forEach(a => {
      lst.push(a.Id);
      a.child.forEach(c => {
        if (c.ProductCode == 'ENT_ETH_UNI_0001') lst.push(c.Id);
      });
    })
    return lst.join('+');
  }

  function getContractTerm() {
    return $scope.selectedAssets().find(item => {
      return item.ContractTerm != null
    }).ContractTerm;
  }

  console.log('assets', $scope.assets);
}]);

vlocity.cardframework.registerModule.filter('startFrom', function () {
  return function (input, start) {
    start = +start;
    return input.slice(start);
  }
});