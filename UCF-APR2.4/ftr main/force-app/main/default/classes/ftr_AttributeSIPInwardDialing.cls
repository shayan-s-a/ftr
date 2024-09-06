public with sharing class ftr_AttributeSIPInwardDialing {
    
    public final static String ProductCode_SIP = 'SIP_TRUNKING_0010';
    public final static String ProductCode_SIP_DIWD= 'SIP_DIRECT_INWARD_DIALING';
    public final static String ProductCode_SIP_LDBT = 'SIP_LD_BLOCK_OF_TIME_INCLUDED';
    public final static String ProductCode_SIP_ITW = 'SIP_INTL_TALK_TO_WORLD';
    public final static String ProductCode_SIP_TFN = 'SIP_TF_NUMBER';
    public final static String ProductCode_SIP_TFAB = 'SIP_TF_ADDITIONAL_BLOCKS';
    public final static String ProductCode_SIP_LDBOT= 'SIP_LD_BLOCK_OF_TIME';
    public final static String ProductCode_SIP_DIDNumber= 'SIP_DID_NUMBER_INCLUDED';
    
    public static void setAttributeSIPInwardDialing(String orderId){
        
        System.debug('::: OrderrID'+orderId);
        List<OrderItem> sipInwardDialingOrderItem = new List<OrderItem>();
        List<OrderItem> sipInwardDialingOrderItemUpdate = new List<OrderItem>();
        List<OrderItem> mainOrderItemsCode = new List<OrderItem>();
        Map<String,Object>  ordItemValues = new Map<string,Object>();
        Map<Id,List<OrderItem>>  productDistributionMap = new Map<Id,List<OrderItem>>();

        List<OrderItem> listOrderItem= [SELECT id,vlocity_cmt__rootitemid__c,uni_host__c,vlocity_cmt__ServiceAccountId__c,
                                        SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,vlocity_cmt__OneTimeCharge__c,Quantity,vlocity_cmt__RecurringCharge__c,vlocity_cmt__EffectiveQuantity__c,
                                        vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__r.ProductCode FROM OrderItem Where OrderId=:orderID ];
        
        if(!listOrderItem.isEmpty()){
            
            for(OrderItem attributeItem : listOrderItem){
              
                System.debug('::::: I am IN 12'+productDistributionMap);
                if(attributeItem.vlocity_cmt__Product2Id__r.ProductCode != ProductCode_SIP_DIWD){

                    if(!productDistributionMap.containsKey(attributeItem.vlocity_cmt__ServiceAccountId__c)){
  
                        productDistributionMap.put(attributeItem.vlocity_cmt__ServiceAccountId__c, new List<OrderItem>());

                   }
                   productDistributionMap.get(attributeItem.vlocity_cmt__ServiceAccountId__c).add(attributeItem);

                }else{
                    sipInwardDialingOrderItem.add(attributeItem);
                }
    }
}

            if(!sipInwardDialingOrderItem.isEmpty()){

               
                for(OrderItem setSIPInward: sipInwardDialingOrderItem){

                    
                       
                     System.debug('Sizes OF List'+ productDistributionMap.get(setSIPInward.vlocity_cmt__ServiceAccountId__c).size());
                      
                      for(OrderItem relatedOrderItem: productDistributionMap.get(setSIPInward.vlocity_cmt__ServiceAccountId__c)){

                        //SIP turking 
                         if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP){

                            setSIPInward.SIPT_quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                            setSIPInward.DPI_SIP_MRC__c   = String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                            setSIPInward.SIP_Code_SIPT__c = relatedOrderItem.SNE_Code_MRC__c; 
                      }
                      //SIP 	LD Block of Time - Included
                      else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_LDBT){

                        setSIPInward.SIP_Code_LDBT__c =  relatedOrderItem.SNE_Code_MRC__c;
                        setSIPInward.SIP_LDBT_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                        setSIPInward.SIP_LDBT_SNE_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                      }
                       //SIP - International Talk to the World
                      else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_ITW){

                        setSIPInward.SIP_Code_ITW__c =  relatedOrderItem.SNE_Code_MRC__c;
                        setSIPInward.SIP_ITW_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                        setSIPInward.SIP_ITW_SNE_Code_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                      }
                         //SIP Toll Free Number
                        else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_TFN){

                            setSIPInward.SIP_Code_TFN__c =  relatedOrderItem.SNE_Code_MRC__c;
                            setSIPInward.SIP_TFN_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                            setSIPInward.SIP_TFN_SNE_Code_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                          }
                            //SIP TF Block of Time - Additional
                        else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_TFAB){

                            setSIPInward.SIP_Code_TFAB__c =  relatedOrderItem.SNE_Code_MRC__c;
                            setSIPInward.SIP_TFAB_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                            setSIPInward.SIP_TFAB_SNE_Code_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                          }
                               //SIP LD Block of Time - Additional
                        else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_LDBOT){

                            setSIPInward.SIP_Code_LDBOT__c =  relatedOrderItem.SNE_Code_MRC__c;
                            setSIPInward.SIP_LDBOT_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                            setSIPInward.SIP_LDBOT_SNE_Code_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                          }
                                     //SIP DID Number - Included
                        else if(relatedOrderItem.vlocity_cmt__Product2Id__r.ProductCode==ProductCode_SIP_DIDNumber){

                            setSIPInward.SIP_Code_DID__c =  relatedOrderItem.SNE_Code_MRC__c;
                            setSIPInward.DID_Quantity__c = String.valueOf(relatedOrderItem.vlocity_cmt__EffectiveQuantity__c);
                            setSIPInward.DID_SNE_Code_MRC__c =  String.valueOf(relatedOrderItem.vlocity_cmt__RecurringCharge__c);
                          }
                    }
                    sipInwardDialingOrderItemUpdate.add(setSIPInward);
                 
                
            }

            if(!sipInwardDialingOrderItemUpdate.isEmpty()){
                System.debug('::: I am IN 9'+sipInwardDialingOrderItemUpdate);
                Update sipInwardDialingOrderItemUpdate;
            }
        }
    }
}