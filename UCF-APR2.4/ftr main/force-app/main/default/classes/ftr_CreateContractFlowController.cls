/**
 *  CreateUpdateContractFlowController
 *
 *  @author: Karthikeya koganti
 *  @date: July 20 2020
 *  @updated: 2020-10-26 for UCF Contract creation - EM
 */

public class ftr_CreateContractFlowController {
  public class ContractCreationException extends Exception {
  }
  //Record type definitions
  public static final String productScheduleRecordTypeName = 'Product Schedule';
  public static final Id productScheduleRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
    .get(productScheduleRecordTypeName)
    .getRecordTypeId();
  public static List<vlocity_cmt__CustomFieldMap__c> lineItemFieldMapper = [
    SELECT Id, vlocity_cmt__DestinationFieldName__c, vlocity_cmt__SourceFieldName__c
    FROM vlocity_cmt__CustomFieldMap__c
    WHERE vlocity_cmt__SourceSObjectType__c = 'QuoteLineItem' AND vlocity_cmt__DestinationSObjectType__c = 'vlocity_cmt__ContractLineItem__c'
  ];
  public static List<vlocity_cmt__CustomFieldMap__c> quoteFieldMapper = [
    SELECT Id, vlocity_cmt__DestinationFieldName__c, vlocity_cmt__SourceFieldName__c
    FROM vlocity_cmt__CustomFieldMap__c
    WHERE vlocity_cmt__SourceSObjectType__c = 'Quote' AND vlocity_cmt__DestinationSObjectType__c = 'Contract'
  ];
  public static final List<String> fsaRecordTypes = new List<String>{
    'Frontier Services Agreement',
    'Community Connections - Agreement',
    'VZ3 Agreement - VEC',
    'VZ3 Agreement - VES'
  };
  public static List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
  public static List<Contract> contractList = new List<Contract>();
  public static Quote currentQuote = new Quote();
  public static Contract fsaContract = new Contract();
  public static String flowCustomerSignedBy;
  public static String flowFrontierSignedBy;
  public static Date flowStartDate;

  // input data from flow
  public class ContractData {
    @InvocableVariable
    public Id quoteId;
    @InvocableVariable
    public String contractType;
    @InvocableVariable
    public String customerSignedBy;
    @InvocableVariable
    public String frontierSignedBy;
    @InvocableVariable
    public Date contractStartDate;
  }

  @InvocableMethod(label='Create Contract' category='Vlocity CLM')
  public static List<List<Id>> createContract(List<ContractData> contractData) {
    try {
      List<Id> contractIds = new List<Id>();
      ftr_CreateContractFlowController.currentQuote = getQuote(contractData[0].quoteId);

      ftr_CreateContractFlowController.quoteLineItems = getQuoteLineItems(contractData[0].quoteId);

      if (contractData[0].contractStartDate != null){
        
        ftr_CreateContractFlowController.flowStartDate = contractData[0].contractStartDate;
      } 
      if (contractData[0].customerSignedBy != null && contractData[0].customerSignedBy !=''){
        
        ftr_CreateContractFlowController.flowCustomerSignedBy = contractData[0].customerSignedBy;
      } 
      
      if (contractData[0].frontierSignedBy != null && contractData[0].frontierSignedBy != '') {
        
        ftr_CreateContractFlowController.flowFrontierSignedBy = contractData[0].frontierSignedBy;
      }

      if (contractData[0].contractType == 'PS') {
        ftr_CreateContractFlowController.fsaContract = [
          SELECT Id, vlocity_cmt__QuoteId__c, RecordTypeId, StartDate
          FROM Contract
          WHERE RecordType.Name IN :fsaRecordTypes AND AccountId = :ftr_CreateContractFlowController.currentQuote.AccountId
          LIMIT 1
        ];

        String[] quoteProducts = ftr_CreateContractFlowController.currentQuote.Products__c.split(';');
        if (ftr_CreateContractFlowController.currentQuote.ftr_IsBundle__c == false) {
          for (ContractCreationConfig__mdt config : [SELECT Id, Products__c, Schedule_Type__c, Agreement_Type__c, Product_Family__c FROM ContractCreationConfig__mdt WHERE IsBundle__c = FALSE]) {
            String[] configProdList = config.Products__c.split(';');
            for (String prod : configProdList) {
              if (quoteProducts.contains(prod)) {
                Id contractId = ftr_CreateContractFlowController.createSpecificContract(config.Schedule_Type__c, config.Agreement_Type__c, config.Product_Family__c);
                contractIds.add(contractId);
                break; // break inner loop to use the next config value to create contract
              }
            }
          }
        } else {
          // if its a custom bundle (i.e. Promotion bundle)
          // create 1 specific contract 
          ContractCreationConfig__mdt contractConfig;
          for (ContractCreationConfig__mdt config : [SELECT Id, Products__c, Schedule_Type__c, Agreement_Type__c, Product_Family__c FROM ContractCreationConfig__mdt WHERE IsBundle__c = TRUE]) {
            String[] configProdList = config.Products__c.split(';');
            for (String prod : configProdList) {
              if (quoteProducts.contains(prod)) {
                contractConfig = config;
              } else {
                contractConfig = null;
                break;
              }
            }
            if (contractConfig != null) {
              Id contractId = ftr_CreateContractFlowController.createSpecificContract(config.Schedule_Type__c, config.Agreement_Type__c, config.Product_Family__c);
              contractIds.add(contractId);
              break; 
            }
          }
          
        }

        // if (ftr_CreateContractFlowController.currentQuote.Products__c.contains('UCF')) {
        //   Id ucfProductScheduleId = ftr_CreateContractFlowController.createSpecificContract('Frontier AnyWare UCaaS', 'VoIP', 'UCF');
        //   contractIds.add(ucfProductScheduleId);
        // }
        // if (
        //   ftr_CreateContractFlowController.currentQuote.Products__c.contains('EIA') ||
        //   ftr_CreateContractFlowController.currentQuote.Products__c.contains('EVPL') ||
        //   ftr_CreateContractFlowController.currentQuote.Products__c.contains('Private Network') 
        // ) {
        //   Id ethernetProductScheduleId = ftr_CreateContractFlowController.createSpecificContract('DIA Schedule_02012021', 'Ethernet/Data Services', 'Ethernet');
        //   contractIds.add(ethernetProductScheduleId);
        // }
        // if (ftr_CreateContractFlowController.currentQuote.Products__c.contains('SDWAN')) {
        //   Id managedServicesProductScheduleId = ftr_CreateContractFlowController.createSpecificContract('SD-WAN', 'Managed Services', 'Managed Services');
        //   contractIds.add(managedServicesProductScheduleId);
        // }
      }

      return new List<List<Id>>{ contractIds };
    } catch (exception e) {
            System.debug(e.getStackTraceString());
      System.debug(e.getMessage());
            throw e;
    }
  }

  public static Id createSpecificContract(String scheduleType, String agreementType, String productFamily) {
    User currentUser = [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
    List<vlocity_cmt__ContractLineItem__c> cLIs = new List<vlocity_cmt__ContractLineItem__c>();

    // populate contract fields
        Contract newContract = new Contract();

    //assign Customer Signer
    if (ftr_CreateContractFlowController.flowCustomerSignedBy != null) {
      newContract.CustomerSignedId = ftr_CreateContractFlowController.flowCustomerSignedBy;
    }
    //assign Frontier Signer
    if (ftr_CreateContractFlowController.flowFrontierSignedBy != null) {
      newContract.CompanySignedId = ftr_CreateContractFlowController.flowFrontierSignedBy;
    }else{
      newContract.CompanySignedId = currentUser.ManagerId;
    }

    //assign Term
    if (ftr_CreateContractFlowController.currentQuote.Service_Term__c != null) {
            newContract.ContractTerm = Integer.valueOf(ftr_CreateContractFlowController.currentQuote.Service_Term__c.substring(0, 2));
        }            
    newContract.FSA__c = ftr_CreateContractFlowController.fsaContract.Id;
    newContract.Agreement_Type__c = agreementType;
    newContract.Schedule_Type__c = scheduleType;
    newContract.RecordTypeId = productScheduleRecordTypeId;
    newContract.Schedule_Type_Purpose__c = ftr_CreateContractFlowController.currentQuote.Schedule_Type_Purpose__c;
    
    
    ////assign Start Date
    newContract.StartDate = ftr_CreateContractFlowController.flowStartDate != null ? ftr_CreateContractFlowController.flowStartDate : Date.today();
    
    for (vlocity_cmt__CustomFieldMap__c fieldMap : ftr_CreateContractFlowController.quoteFieldMapper) {
      String[] fields = fieldmap.vlocity_cmt__SourceFieldName__c.split('\\.');
      if (fields.size() == 1) {
        if (ftr_CreateContractFlowController.currentQuote.get(fields[0]) != null && ftr_CreateContractFlowController.currentQuote.get(fields[0]) != '') {
          newContract.put(fieldMap.vlocity_cmt__DestinationFieldName__c, ftr_CreateContractFlowController.currentQuote.get(fieldmap.vlocity_cmt__SourceFieldName__c));
        }
      } else if (fields.size() == 2) {
        if (
          ftr_CreateContractFlowController.currentQuote.getSObject(fields[0]).get(fields[1]) != null &&
          ftr_CreateContractFlowController.currentQuote.getSObject(fields[0]).get(fields[1]) != '' &&
          ftr_CreateContractFlowController.currentQuote.getSObject(fields[0]) != null
        ) {
          newContract.put(fieldMap.vlocity_cmt__DestinationFieldName__c, ftr_CreateContractFlowController.currentQuote.getSObject(fields[0]).get(fields[1]));
        }
      }
    }

    // associate quote
    if (ftr_CreateContractFlowController.fsaContract.vlocity_cmt__QuoteId__c == null) {
      ftr_CreateContractFlowController.fsaContract.vlocity_cmt__QuoteId__c = ftr_CreateContractFlowController.currentQuote.Id;
      ftr_CreateContractFlowController.contractList.add(ftr_CreateContractFlowController.fsaContract);
    }

    // need to insert contract to associate line items
    insert newContract;

    // create contract line items copied from quotelineitems, UCF is standalone
    for (QuoteLineItem qli : ftr_CreateContractFlowController.quoteLineItems) {
          if ((qli.Product_Family__c == productFamily || productFamily == 'All') && qli.vlocity_cmt__Action__c != 'Disconnect')
        cLIs.add(ftr_CreateContractFlowController.createContractLineItem(qli, newContract.Id));
    }

    // insert contract line items
    insert cLIs;

    ftr_CreateContractFlowController.setProductsField(newContract);

    // return the newly created contract Id
    return newContract.Id;
  }

  public static vlocity_cmt__ContractLineItem__c createContractLineItem(QuoteLineItem qli, Id contractId) {
    vlocity_cmt__ContractLineItem__c contractLineItem = new vlocity_cmt__ContractLineItem__c();
    contractLineItem.vlocity_cmt__ContractId__c = contractId;
    for (vlocity_cmt__CustomFieldMap__c fieldmap : ftr_CreateContractFlowController.lineItemFieldMapper) {
      String[] fields = fieldmap.vlocity_cmt__SourceFieldName__c.split('\\.');
      if (fields.size() == 1) {
        if (qli.get(fields[0]) != null && qli.get(fields[0]) != '') {
          contractLineItem.put(fieldMap.vlocity_cmt__DestinationFieldName__c, qli.get(fieldmap.vlocity_cmt__SourceFieldName__c));
        }
      } else if (fields.size() == 2) {
        if (
          qli.getSObject(fields[0]).get(fields[1]) != null &&
          qli.getSObject(fields[0]).get(fields[1]) != '' &&
          qli.getSObject(fields[0]) != null
        ) {
          contractLineItem.put(fieldMap.vlocity_cmt__DestinationFieldName__c, qli.getSObject(fields[0]).get(fields[1]));
        }
      }
    }

        contractLineItem.vlocity_cmt__EffectiveStartDate__c = ftr_CreateContractFlowController.flowStartDate != null ? ftr_CreateContractFlowController.flowStartDate + 1 : Date.today()+ 1;
        
    return contractLineItem;
  }

  public static List<QuoteLineItem> getQuoteLineItems(String quoteId) {
    Set<String> fields = new Set<String>{ 'QuoteId', 'Product_Family__c', 'vlocity_cmt__Action__c' };
    for (vlocity_cmt__CustomFieldMap__c fieldmap : ftr_CreateContractFlowController.lineItemFieldMapper) {
      fields.add(fieldmap.vlocity_cmt__SourceFieldName__c);
    }

    String query = String.format(
      'SELECT {0} FROM QuoteLineItem WHERE QuoteId=:quoteId LIMIT 1000',
      new List<String>{ String.join(new List<String>(fields), ', ') }
    );
    return (List<QuoteLineItem>) Database.Query(query);
  }

  public static Quote getQuote(String quoteId) {
    Set<String> fields = new Set<String>{'Service_Term__c', 'AccountId', 'Products__c', 'ftr_IsBundle__c', 'Schedule_Type_Purpose__c' };
    for (vlocity_cmt__CustomFieldMap__c fieldmap : ftr_CreateContractFlowController.quoteFieldMapper) {
      fields.add(fieldmap.vlocity_cmt__SourceFieldName__c);
    }

    String query = String.format(
      'SELECT {0} FROM Quote WHERE Id=:quoteId',
      new List<String>{ String.join(new List<String>(fields), ', ') }
    );
    return (Quote) Database.Query(query);
  }

  /*
  * @description populate the Products__c field
  */
  public static void setProductsField(Contract con) {
    ProductsFieldConfig__mdt[] fieldConfigs = [SELECT Field__c, FieldValue__c, PicklistValue__c FROM ProductsFieldConfig__mdt];
    vlocity_cmt__ContractLineItem__c[] cLIs = [ SELECT Id, vlocity_cmt__Product2Id__r.Family, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c 
                          FROM vlocity_cmt__ContractLineItem__c 
                          WHERE vlocity_cmt__ContractId__c = :con.Id];
    // group CLIs by Contract
    Set<String> products = new Set<String>();
    for (vlocity_cmt__ContractLineItem__c item : cLIs) {
      for (ProductsFieldConfig__mdt config : fieldConfigs) {
                if (item.vlocity_cmt__Product2Id__r.get(config.Field__c) == config.FieldValue__c) {
                    products.add(config.PicklistValue__c);
                }
            }
    }

    con.Products__c = String.join(new List<String>(products), ';');
    
    update con;

  }
}