vlocity.cardframework.registerModule.controller('vltStepController', ['$scope','$rootScope','$window','$q', 'bpService', function ($scope, $rootScope, $window, $q, bpService) {
    const webinarProducts = [
        'UCF_WEBINAR_100',
        'UCF_WEBINAR_1000',
        'UCF_WEBINAR_500'
    ];
    const collabProducts = [
        'UCF_COLLAB_10',
        'UCF_COLLAB_100',
        'UCF_COLLAB_200',
        'UCF_COLLAB_25',
        'UCF_COLLAB_300',
        'UCF_COLLAB_500'
    ];
    const allPhones = [
        'UCF_ATA_PAGADPT',
        'UCF_YEALNK_T31G',
        'UCF_YEALNK_T53',
        'UCF_YEALNK_T33G',
        'UCF_YEALNK_T53W',
        'UCF_YEALNK_T57W',
        'UCF_YEALNK_T54W',
        'UCF_POLY_8300_CONFERENCE',
        'UCF_POLY_8800_CONFERENCE',
        'UCF_POLY_EDGE_E220',
        'UCF_YEALNK_T58W',
        'UCF_YEALNK_W90B_BASE',
        'UCF_YEALNK_W90M',
        'UCF_POLY_EDGE_E450',
        'UCF_POLY_EDGE_E350',
        'UCF_POLY_EDGE_E550',
        'UCF_YEALINK_CP935W_STANDALONE',
        'UCF_YEALINK_CP935W_BASE',
        'UCF_2_PORT_ATA',
        'UCF_4_PORT_ATA',
        'UCF_8_PORT_ATA',
        'UCF_YEALNK_CP965S',
        'UCF_YEALNK_W70B_BASE',
        'UCF_YEALNK_WP76P'
    ]
    const phonesYealink=[
        'UCF_YEALNK_T31G',
        'UCF_YEALNK_T53',
        'UCF_YEALNK_T33G',
        'UCF_YEALNK_T53W',
        'UCF_YEALNK_T57W',
        'UCF_YEALNK_T54W',
        'UCF_YEALNK_T58W',
        'UCF_YEALNK_W90B_BASE',
        'UCF_YEALNK_W90M',
        'UCF_YEALINK_CP935W_STANDALONE',
        'UCF_YEALINK_CP935W_BASE',
        'UCF_YEALNK_CP965S',
        'UCF_YEALNK_W70B_BASE',
        'UCF_YEALNK_WP76P'
    ];
    const phonesPoly=[
        'UCF_POLY_8300_CONFERENCE',
        'UCF_POLY_8800_CONFERENCE',
        'UCF_POLY_EDGE_E220',
        'UCF_POLY_EDGE_E450',
        'UCF_POLY_EDGE_E350',
        'UCF_POLY_EDGE_E550'
    ];
    const accPoly=[
        'UCF_POLY_EDGE_EEM',
        'UCF_POLY_EXPAN_MICS_FOR_CONF_PHONES',
        'UCF_POLY_EDGE_E_500_550_POWER',
        'UCF_POLY_EDGE_E_POWER_SUPPLY',
        'UCF_POLY_TRIO_8300_POWER_KIT',
        'UCF_POLY_TRIO_8800_POWER_KIT'
    ];
    const accYealink=[
        'UCF_YEALNK_CPW56_EXP_MICS_FOR_CP965_CONF_PHONES',
        'UCF_YEALNK_T54_57_58W',
        'UCF_YEALNK_BH72_BLK',
        'UCF_YEALNK_BH72_GRY',
        'UCF_YEALNK_BH76_Black',
        'UCF_YEALNK_BH76_Gray',
        'UCF_YEALNK_BLT60',
        'UCF_YEALNK_BT41_BLUTOOTH',
        'UCF_YEALNK_POE_INJECTOR',
        'UCF_YEALNK_T3_PWR',
        'UCF_YEALNK_T53_T54_WM',
        'UCF_YEALNK_UH36_DUAL_HS',
        'UCF_YEALNK_UH36_MONO_HS',
        'UCF_YEALNK_WF50_WIFI',
        'UCF_YEALNK_WH62_DUAL_HS',
        'UCF_YEALNK_WH62_MONO_HS',
        'UCF_YEALNK_EXP50',
        'UCF_YEALNK_W59R_DECT',
        'UCF_YEALNK_W56H_DECT_HS',
        'UCF_YEALNK_T53_T54_PWR',
        'UCF_POWER_CORD_BH72_77'
    ];

    $scope.lastStepName = getLastStepName();
    
    $scope.navigateToCart = function (step) {
        var formId = $scope.bpTree.sOmniScriptId + '-' + step.indexInParent;
        if(!$scope.checkValidity($scope,null,null,'StepNext',formId) && stepIsValid(step)) {
            var dest = '/apex/%vlocity_namespace%__hybridcpq?id=' + $scope.bpTree.response.ContextId;
            if ($rootScope.sforce) {
                $rootScope.sforce.one.navigateToURL(dest,true);
            } else {
                $window.open('..'+dest, "_self");
            }
        }
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
            if(step.name != $scope.lastStepName) {
                $scope.nextRepeater(step.nextIndex, step.indexInParent);
            } else if (step.name == $scope.lastStepName) {
                if (parseInt(getElementValue('SelectServiceLocation.CountOfLocations')) > 1) {
                    // gotoStep('SelectServiceLocation');
                    saveQuestionnaireData(step);
                }
            }
        }

    }

    function saveQuestionnaireData(step) {
        var input = {
            DRParams: $scope.bpTree.response,
            Bundle: 'UCFQuoteSaveQuestionnaireData'
        };
        var configObj = {
            sClassName: '%vlocity_namespace%.DefaultDROmniScriptIntegration',
            sMethodName: 'invokeOutboundDR',
            input: angular.toJson(input),
            options: angular.toJson({ "useQueueableApexRemoting": false })
        };
        executeRemoteAction(configObj, step);
    }

    function executeRemoteAction(configObj, step) {
        $rootScope.loading = true;
        return $q(function (resolve, reject) {
            bpService.OmniRemoteInvoke(configObj).then(function (result) {
                var remoteResp = angular.fromJson(result);
                
                console.info('Result: ', result);
                $scope.nextRepeater($scope.getStep('InitializeQuoteJourney').indexInParent, step.indexInParent);

                resolve(remoteResp)
            }).catch(function (error) {
                console.error('Error while calling DR ', error);
                alert(JSON.stringify(error));
                $rootScope.loading = false;
                reject(error);
            });
        });
    }
    
    function getLastStepName () {
        for (var i = $scope.bpTree.children.length - 1; i >= 0; i--) {
            if ($scope.bpTree.children[i].type == 'Step') {
                return $scope.bpTree.children[i].name;
            }
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

        if (step.name == 'SelectServiceLocation') {
            if (!$scope.bpTree.response[step.name]['CurrentLocationId']) {
                $scope.modal.msgs.push('⦿ Service location is required.');
            }
            if (!$scope.bpTree.response[step.name]['PrimaryLocationId']) {
                $scope.modal.msgs.push('⦿ Primary location needs to be set.');
            }
            if (!$scope.bpTree.response[step.name]['ServiceTerm']) {
                $scope.modal.msgs.push('⦿ Service term is required.');
            }
            // if no errors, set term
            // if ($scope.modal.msgs.length == 0) {
            //     $scope.bpTree.response.osData.UCFTerm = $scope.bpTree.response[step.name]['ServiceTerm'];
            // }

               if ($scope.modal.msgs.length == 0) {
                if (getElementValue('isBundle')) {
                    let osData = getElementValue('osData');
                    if (!Array.isArray(osData)) {
                        osData = [osData];
                    }
                    var idx = 0;
                    // check if it's already in there, 1 per service account
                    for (let i=0; i<osData.length;i++) {
                        if (osData[i].ServiceAccountId == $scope.bpTree.response[step.name]['CurrentLocationId']) {
                            idx = i;
                        }
                    }
                    
                    setElementValue('CurrentProduct', null);
                    setElementValue('CurrentProduct', osData[idx]);
                }
            }

        } else if (step.name == 'VOIPQualification') {            

            // if qualification has an Id, means they selected an existing one. Allow them to proceed.

            if (!getElementValue('VOIPQualifications')[0]) {
                if (getElementValue('Qualification.success') != true) {
                    $scope.modal.msgs.push('⦿ NPA/NXX Qualification is required.');

                } else if (getElementValue('VoipQualUpsertResult.success') != true) {
                    $scope.modal.msgs.push('⦿ Please add the NPA/NXX for this location.');
                }
            }            

        } else if (step.name == 'LicSelection') {
            $scope.webfaxLicenseCount = getCountOfRecords('ProductCode', 'UCF_WEBFAX');
            $scope.ucfExecutiveLic_count = getCountOfRecords('ProductCode', 'UCF_EXEC_LIC');
            $scope.ucfBasicLic_count = getCountOfRecords('ProductCode', 'UCF_BASIC_LIC');
            var basicAndExecutiveSum = $scope.ucfBasicLic_count+ $scope.ucfExecutiveLic_count;
            
            if ($scope.webfaxLicenseCount>0 && basicAndExecutiveSum<1){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ UCF Inbound WebFax DID must have a UCF Executive license or a UCF Basic license.');
            }  

            if ($scope.bpTree.response.LicSelection.LicensingQuestions.ExternalPagingFaxAvailability == 'True' && getCountOfRecords('ProductCode', 'UCF_ANALOG_LIC') <= 0) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The cart must contain the "UCF Analog" license.');
            }

            var analogLicenseCount = getCountOfRecords('ProductCode', 'UCF_ANALOG_LIC');
            if (analogLicenseCount > 0 && getCountOfRecordsList('ProductCode', ['UCF_ATA_PAGADPT', 'UCF_2_PORT_ATA', 'UCF_4_PORT_ATA', 'UCF_8_PORT_ATA']) <= 0) {
                $scope.modal.isError = false;
                $scope.modal.cancelLabel = 'Cancel';
                $scope.modal.continueLabel = 'Proceed';
                $scope.modal.title = 'Acknowledgment';
                $scope.modal.msgs.push('⦿ ATA port is required for Analog licenses.');
            }
        } else if (step.name == 'PhoneSelection') {
            $scope.numberOfBasicLicenses = getCountOfRecordsFromCurrentLocation('ProductCode', 'UCF_BASIC_LIC', $scope.bpTree.response.CurrentLocationId);
            $scope.numberOfLicenses = getCountOfRecords('Product2.%vlocity_namespace%__Type__c', 'License');
            $scope.totalNumberOfPhonesByLocation = getCountOfRecordsListFromCurrentLocation('ProductCode', allPhones, $scope.bpTree.response.CurrentLocationId);
            $scope.totalNumberOfPhones = getCountOfRecordsList('ProductCode', allPhones);
            var isErroMessage = false;

            var existingCharges = {
                InstallationCharges: getRecordIds('ProductCode', 'UCF_INST_CHG_PH'),
                WarrantyCharges: getRecordIds('ProductCode', 'UCF_WRNTY_PH'),
                E911Charges: getRecordIds('ProductCode', 'UCF_ADDL_E911'),
                SwitchInstallationCharges: getRecordIds('ProductCode', 'UCF_INST_CHG_SWITCH')
            };
            var phoneCount = {
                Purchased: getCountOfPhonesByAttribute('ATTR_BUYING_OPTION', 'Purchase'),
                Rented: getCountOfPhonesByAttribute('ATTR_BUYING_OPTION', 'Rent'),
                TotalQuantity: $scope.totalNumberOfPhones
            };
            setElementValue('PhoneCount', phoneCount);
            setElementValue('GetExistingCharges', existingCharges);

            $scope.numberOfYealink = getCountOfRecordsList('ProductCode', phonesYealink);
            $scope.numberOfPoly = getCountOfRecordsList('ProductCode', phonesPoly);

            if($scope.numberOfYealink>0&&$scope.numberOfPoly>0){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ If Yealink has been added to the cart then Poly can\'t be added as well, and vice versa.');
                isErroMessage = true;
            } 

            if ($scope.bpTree.response.LicSelection.LicensingQuestions.ExternalPagingFaxAvailability == 'True' && getCountOfRecordsList('ProductCode', ['UCF_ATA_PAGADPT', 'UCF_2_PORT_ATA', 'UCF_4_PORT_ATA', 'UCF_8_PORT_ATA']) <= 0) {
                $scope.modal.isError = true;
                // $scope.modal.msgs.push('The cart must contain one of the following equipment: UCF 2 Port ATA, UCF 4 Port ATA, UCF 8 Port ATA or UCF ATA and Paging Adapter');
                $scope.modal.msgs.push('⦿ The cart must contain one of the following equipment:');
                $scope.modal.msgs.push('– UCF 2 Port ATA');
                $scope.modal.msgs.push('– UCF 4 Port ATA');
                $scope.modal.msgs.push('– UCF 8 Port ATA');
                $scope.modal.msgs.push('– UCF ATA and Paging Adapter');
                isErroMessage = true;
            }

            if (isErroMessage) {
                $scope.showModal();
                return false;
            }

            if ($scope.numberOfBasicLicenses > $scope.totalNumberOfPhonesByLocation) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The number of basic licenses in the cart is greater than the number of phones for the current location (' + $scope.bpTree.response.SelectServiceLocation.CurrentLocationName + ').');
            } else if ($scope.numberOfLicenses < $scope.totalNumberOfPhones) {
                $scope.modal.isError = false;
                $scope.modal.cancelLabel = 'Cancel';
                $scope.modal.continueLabel = 'Proceed';
                $scope.modal.title = 'Acknowledgment';
                $scope.modal.msgs.push('⦿ The number of licenses in the cart is less than the number of phones.');
            }

        } else if (step.name == 'AddOnSelection') {
            $scope.numberOfExecLicenses = getCountOfRecordsFromCurrentLocation('ProductCode', 'UCF_EXEC_LIC', $scope.bpTree.response.CurrentLocationId);
            $scope.numberOfWebinars = getCountOfRecordsListFromCurrentLocation('ProductCode', webinarProducts, $scope.bpTree.response.CurrentLocationId);
            $scope.numberOfCollab = getCountOfRecordsListFromCurrentLocation('ProductCode', collabProducts, $scope.bpTree.response.CurrentLocationId);
            let maxBetweenWebandColab = Math.max($scope.numberOfCollab, $scope.numberOfWebinars);
            if ($scope.numberOfWebinars || $scope.numberOfCollab) {
                if ($scope.numberOfExecLicenses == 0) {
                    $scope.modal.isError = true;
                    $scope.modal.msgs.push('⦿ At least one UCF Executive license needs to be purchased in order to be able to select any Collaboration and/or Webinar add ons for the current location (' + $scope.bpTree.response.SelectServiceLocation.CurrentLocationName + ').');
                } else if ($scope.numberOfExecLicenses < maxBetweenWebandColab) {
                    $scope.modal.isError = true;
                    $scope.modal.msgs.push('⦿ You need at least the same amount of UCF Executive Licenses as Collaboration or Webinar items for the current location (' + $scope.bpTree.response.SelectServiceLocation.CurrentLocationName + ').');
                }
            }

            /*CMEP-4*/
            $scope.callRecordingBasic_count = getCountOfRecords('ProductCode', 'UCF_CR_BASIC');
            $scope.ucfBasicLic_count = getCountOfRecords('ProductCode', 'UCF_BASIC_LIC');
            $scope.ucfExecutiveLic_count = getCountOfRecords('ProductCode', 'UCF_EXEC_LIC');
            $scope.ucfAudioMining_count = getCountOfRecords('ProductCode', 'UCF_CR_AUDIO_MINING');
            $scope.ucfScreenRecord_count = getCountOfRecords('ProductCode', 'UCF_CR_SCREEN_RECORD');
            $scope.ucfStorage180_count = getCountOfRecords('ProductCode', 'UCF_CR_STORAGE_180');
            $scope.ucfStorage1Yr_count = getCountOfRecords('ProductCode', 'UCF_CR_STORAGE_1YR');
            $scope.ucfStorage2Yr_count = getCountOfRecords('ProductCode', 'UCF_CR_STORAGE_2YR');
            $scope.ucfStorage3Yr_count = getCountOfRecords('ProductCode', 'UCF_CR_STORAGE_3YR');

            if($scope.callRecordingBasic_count>0 && $scope.callRecordingBasic_count>($scope.ucfBasicLic_count+ $scope.ucfExecutiveLic_count)){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The amount of Call Recording Basic cannot be greater than the amount of Basic and Excecutive licenses in the cart');
            } else if ($scope.ucfAudioMining_count>$scope.callRecordingBasic_count){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The amount of Audio Mining cannot be greater than the amount of Call Recording Basic in the cart');
            } else if($scope.ucfScreenRecord_count>$scope.callRecordingBasic_count){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The amount of Screen Record cannot be greater than the amount of Call Recording Basic in the cart');
            } else if(( $scope.ucfStorage180_count+ $scope.ucfStorage1Yr_count+ $scope.ucfStorage2Yr_count+ $scope.ucfStorage3Yr_count)>$scope.callRecordingBasic_count){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The amount of storage selected cannot be greater than the amount of Call Recording Basic in the cart');
            }
            
            if ($scope.bpTree.response.AddOnSelection.AddOnQuestions.TollFreeServicesRequired == 'True' && getCountOfRecordsList('ProductCode', ['UCF_TOLL_FREE_LIC', 'UCF_TF_ADDL_BLOCKS', 'UCF_TF_MIN_BLOCKS']) <= 0) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The cart must contain one of the following toll-free products:');
                $scope.modal.msgs.push('– Toll Free Number');
                $scope.modal.msgs.push('– Toll Free - Additional Block of time');
                $scope.modal.msgs.push('– Toll Free Minute Blocks');
            }

            if ($scope.bpTree.response.AddOnSelection.AddOnQuestions.MultipleAutoAttendantsRequirement == 'True' && getCountOfRecords('ProductCode', 'UCF_PREM_AUTO_ATTEND') <= 1) {
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The cart must contain two or more of the "UCF Premium Auto Attendant" product.');
            }

            
        } else if (step.name == 'AccessorySelection'){
            $scope.numberOfYealinkPhones = getCountOfRecordsList('ProductCode', phonesYealink);
            $scope.numberOfYealinkAcc = getCountOfRecordsList('ProductCode', accYealink);
            $scope.numberOfPolyPhones = getCountOfRecordsList('ProductCode', phonesPoly);
            $scope.numberOfPolyAcc = getCountOfRecordsList('ProductCode', accPoly);
            
            if($scope.numberOfYealinkAcc>0 && $scope.numberOfPolyPhones>0){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ Cannot select a Yealink accessory having a Polycom phone in the cart.');
            }
            
            if($scope.numberOfPolyAcc>0 && $scope.numberOfYealinkPhones>0){
                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ Cannot select a Polycom accessory having a Yealink phone in the cart.');
            }
            
            if ((   $scope.bpTree.response.AccessorySelection.AccessoriesQuestions.PhonePowerSource == 'Power Adapters' 
                    || $scope.bpTree.response.AccessorySelection.AccessoriesQuestions.PhonePowerSource == 'Both') 
                    && getCountOfRecordsList('ProductCode', [
                        'UCF_YEALNK_POE_INJECTOR',
                        'UCF_YEALNK_POWER_CORD_BH72_76',
                        'UCF_YEALNK_T3_PWR',
                        'UCF_YEALNK_T53_T54_PWR',
                        'UCF_YEALNK_T54_57_58W',
                        'UCF_POLY_EDGE_E_POWER_SUPPLY',
                        'UCF_POLY_EDGE_E_500_550_POWER',
                        'UCF_POLY_TRIO_8300_POWER_KIT',
                        'UCF_POLY_TRIO_8800_POWER_KIT'
                    ]) <= 0) {

                $scope.modal.isError = true;
                $scope.modal.msgs.push('⦿ The cart must contain one of the following products:');
                $scope.modal.msgs.push('– UCF Yealink Poe Injector');
                $scope.modal.msgs.push('– UCF Yealink Power cord BH72/76');
                $scope.modal.msgs.push('– UCF Yealink T3 Pwr');
                $scope.modal.msgs.push('– UCF Yealink T53 & T53W power adaptor');
                $scope.modal.msgs.push('– UCF Yealink T54W, T57W & T58W');
                $scope.modal.msgs.push('– UCF Poly Edge E Power supply');
                $scope.modal.msgs.push('– UCF Poly Edge E 500/550 Power supply');
                $scope.modal.msgs.push('– UCF Poly Trio 8300 Power Kit');
                $scope.modal.msgs.push('– UCF Poly Trio 8800 Power Kit');
            }

        } else {
            console.info('ELSE');
        }

        if ($scope.modal.msgs.length > 0) {
            $scope.showModal();
            return false;
        }
        return true;
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

    function getCountOfPhonesByAttribute (attributeName, filterValue) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue('Product2.%vlocity_namespace%__SubType__c', item) == 'VOIP Phone') {
                var attributeCategories = getElementValue('attributeCategories', item);
                if (attributeCategories && attributeCategories.records) {
                    var skipItem = false;
                    // check if its a discount or add on first, if so, skip item and dont add to count
                    for (let i=0; i < attributeCategories.records.length; i++) {
                        if (attributeCategories.records[i].productAttributes && attributeCategories.records[i].productAttributes.records) {
                            var attributes = attributeCategories.records[i].productAttributes.records;
                            for (let j=0 ; j < attributes.length; j++) {
                                if ((attributes[j].code == 'ATTR_IS_DISCOUNT' || attributes[j].code == 'ATTR_IS_ADD_ON') && attributes[j].userValues == 'Yes') {
                                   skipItem = true;
                                }
                            }
                        }
                    }
                    if (!skipItem) {
                        for (let i=0; i < attributeCategories.records.length; i++) {
                            if (attributeCategories.records[i].productAttributes && attributeCategories.records[i].productAttributes.records) {
                                var attributes = attributeCategories.records[i].productAttributes.records;
                                for (let j=0 ; j < attributes.length; j++) {
                                    if (attributes[j].code == attributeName && attributes[j].userValues == filterValue) {
                                        count += parseInt(getElementValue('Quantity.value', item));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });
        return count;
    }

    function getCountOfRecords (field, filterValue) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue(field, item) == filterValue) {
                count += parseInt(getElementValue('Quantity.value', item));
            }
        });
        return count;
    }

    function getCountOfRecordsFromCurrentLocation(field, filterValue, currentLocation) {
        var count = 0;
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            console.info("Item: ", item);
            console.info("Current Location: ", currentLocation);
            if (getElementValue(field, item) == filterValue  && item.%vlocity_namespace%__ServiceAccountId__r.Id == currentLocation) {
                count += parseInt(getElementValue('Quantity.value', item));
            }
            console.info(item.name + ': ', count);
        });
        return count;
    }

    function getCountOfRecordsList(field, fitlerValues) {
        var count = 0;
        for (let i=0; i< fitlerValues.length; i++) {
            count += getCountOfRecords(field, fitlerValues[i]);
        }
        return count;
    }

    function getCountOfRecordsListFromCurrentLocation(field, fitlerValues, currentLocation) {
        var count = 0;
        for (let i=0; i< fitlerValues.length; i++) {
            count += getCountOfRecordsFromCurrentLocation(field, fitlerValues[i], currentLocation);
        }
        return count;
    }

    function getRecordIds (field, filterValue) {
        var idList = [];
        angular.forEach($scope.bpTree.response.vlcPersistentComponent.vlcCart.records, function(item) {
            if (getElementValue(field, item) == filterValue) {
                idList.push({ Id: getElementValue('Id.value', item) });
            }
        });
        return idList;
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