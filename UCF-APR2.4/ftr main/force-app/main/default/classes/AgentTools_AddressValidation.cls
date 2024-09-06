global class AgentTools_AddressValidation {
    public String SelectedCriteria = 'Address';
    public RequestedAddress singleAddressLookup {get;set;}
    public List<RequestedAddress> multipleAddressLookup {get;set;}
    public List<ServiceAddress> ServiceAddresses {get;set;}
    public Integer SelectedRecordId {get;set;}
    public ServiceAddress SelectedRecord {get;set;}
    public Boolean DisplayPopup {get;set;}
    public string err = '';
    Map<String,String> technologyMap = new Map<String,String>();
    public string potsAvailableFlag {get;set;}
    public Boolean potsHsicapable {get;set;}
    public Boolean potsFibercapable {get;set;}
    public String toAddress {get;set;}
    public String setReplyTo {get;set;}
    public List<ServiceAddressWrapper> objServiceAddress {get;set;}

    global class LeadObject 
    {
         global string Street {get;set;}
         global string City {get;set;}
         global string StateCode {get;set;}
         global string State {get;set;}
         global string PostalCode {get;set;}
         global String Telephone {get;set;}
        global String environment {get;set;}
        global String controlNumber {get;set;}
    }
    
    global AgentTools_AddressValidation(LeadObject this_lead){
        singleAddressLookup = new RequestedAddress();
        singleAddressLookup.Street = this_lead.Street;
        singleAddressLookup.City = this_lead.City;
        //singleAddressLookup.StateOrProvince = this_lead.StateCode;
        singleAddressLookup.StateOrProvince = this_lead.State;
        singleAddressLookup.PostalCode = this_lead.PostalCode;
        singleAddressLookup.Phone = this_lead.Telephone;
        singleAddressLookup.environment = this_lead.environment;
        singleAddressLookup.controlNumber = this_lead.controlNumber;
        ServiceAddresses = new List<ServiceAddress>();
        DisplayPopup = FALSE;
    }
    
    /*
    public AgentTools_AddressValidation(ApexPages.StandardController SC){
      if (!Test.isRunningTest()) { 
        SC.addFields(new String[]{'Street','City','State','PostalCode','Telephone'});
      }
        LeadObject this_lead = (LeadObject)SC.getRecord();
        singleAddressLookup = new RequestedAddress();
        singleAddressLookup.Street = this_lead.Street;
        singleAddressLookup.City = this_lead.City;
        //singleAddressLookup.StateOrProvince = this_lead.StateCode;
        singleAddressLookup.StateOrProvince = this_lead.State;
        singleAddressLookup.PostalCode = this_lead.PostalCode;
        singleAddressLookup.Phone = this_lead.Telephone;
        ServiceAddresses = new List<ServiceAddress>();
    }*/
    
    public ServiceAddressWrapper getServiceAddressDetail(){
        /*for(ServiceAddressWrapper this_record:objServiceAddress){
            if(this_record.RecordId == SelectedRecordId){
                SelectedRecord = this_record;
            }
        }*/
        return objServiceAddress != null && !objServiceAddress.isEmpty()? objServiceAddress[0] : null ;
    }
    
    public void ShowPopup() {
        /*for(ServiceAddress this_record:ServiceAddresses){
            if(this_record.RecordId == SelectedRecordId){
                SelectedRecord = this_record;
            }
        }
        system.debug(logginglevel.info,selectedrecord);*/
        DisplayPopup = TRUE;
    }
    
    public void HidePopup(){
        //SelectedRecord = new ServiceAddress();
        DisplayPopup = FALSE;
    }
    
    public void EmailError(Exception e){
        toAddress = System.Label.AddressValidation_toAddresses;
    	setReplyTo = System.Label.AddressValidation_setReplyTo;
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{toAddress}; //{'mohan.talluri@ftr.com'};
        mail.setToAddresses(toAddresses);
         
        mail.setReplyTo(setReplyTo);
        mail.setSenderDisplayName('Salesforce Automation');
        mail.setSubject(e.getTypeName() + ' - ' + e.getMessage());
        mail.setPlainTextBody('Stacktrace:\n\n' + e +'\n'+e.getStackTraceString()+'\n RequestAddress:  '+singleAddressLookup+'\n err'+err+'\n\n' + 'User Email: ' + userinfo.getUserEmail());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
    public WS_ESB_ManageAddress.ManageAddressGetAddressRequest RTN_Request(){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest AddressRequest = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        AddressRequest.RequestCriteria.TelephoneNumber = new WS_ESB_BusinessObjects.TelephoneNumber();
        AddressRequest.RequestCriteria.TelephoneNumber.Number_x = singleAddressLookup.Phone.replaceAll('[^0-9]', '');
        AddressRequest.RequestCriteria.Action = 'RetrieveServiceAddress';
        return AddressRequest;
    }
    
    public WS_ESB_ManageAddress.ManageAddressGetAddressRequest RPSA_Request(){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest AddressRequest = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        WS_ESB_BusinessObjects.AddressType AddressType = new WS_ESB_BusinessObjects.AddressType();                      
        WS_ESB_BusinessObjects.AddressText AddressText = new WS_ESB_BusinessObjects.AddressText();
        AddressText.AddressText = singleAddressLookup.Street;
        AddressText.SequenceNumber = 1;     
        AddressType.PostalAddress.AddressText.add(AddressText);     
        AddressType.PostalAddress.Locality = singleAddressLookup.City;
        AddressType.PostalAddress.StateOrProvince = singleAddressLookup.StateOrProvince;
        AddressType.PostalAddress.Postcode = singleAddressLookup.PostalCode;
        AddressRequest.RequestCriteria.Action = 'RetrievePostalAndServiceAddress';
        AddressRequest.RequestCriteria.Address = AddressType;
        return AddressRequest;
    }
    
    public WS_ESB_ManageAddress.ManageAddressGetAddressRequest RSA_Request(){
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest AddressRequest = new WS_ESB_ManageAddress.ManageAddressGetAddressRequest();
        WS_ESB_BusinessObjects.AddressType AddressType = new WS_ESB_BusinessObjects.AddressType();                      
        WS_ESB_BusinessObjects.AddressText AddressText = new WS_ESB_BusinessObjects.AddressText();
        AddressText.AddressText = singleAddressLookup.Street;
        AddressText.SequenceNumber = 1;     
        AddressType.PostalAddress.AddressText.add(AddressText);     
        AddressType.PostalAddress.Locality = singleAddressLookup.City;
        AddressType.PostalAddress.StateOrProvince = singleAddressLookup.StateOrProvince;
        AddressType.PostalAddress.PostCode = singleAddressLookup.PostalCode;
        AddressRequest.RequestCriteria.Action = 'RetrieveServiceAddress';
        AddressRequest.RequestCriteria.Address = AddressType;
        system.debug('Address Request:\n\n' + AddressRequest);
        return AddressRequest;
    }
    
    //public API_Callout__c LOG_API(Datetime StartTime, Map<String,String> OutputHeaders){
    //  API_Callout__c API_CALLOUT = new API_Callout__c();
    //  API_CALLOUT.DateTime__c = StartTime;
    //  API_CALLOUT.Duration__c = datetime.now().getTime() - StartTime.getTime();
    //  String this_status = OutputHeaders.get(null);           
    //  API_CALLOUT.StatusProtocol__c = this_status.left(this_status.indexOf(' '));
    //  API_CALLOUT.StatusCode__c = this_status.substring(this_status.indexOf(' '));
    //  API_CALLOUT.ClientIPs__c = OutputHeaders.get('X-Client-IP');
    //  return API_CALLOUT;
    //}
    //public API_Callout__c LOG_API(Datetime StartTime, Exception e){
    //  API_Callout__c API_CALLOUT = new API_Callout__c();
    //  API_CALLOUT.DateTime__c = StartTime;
    //  API_CALLOUT.StatusMessage__c = e.getMessage();
    //  return API_CALLOUT;
    //}
      
       
    
    public void ResetFields(){
        singleAddressLookup = new RequestedAddress();
        if(!ServiceAddresses.isEmpty()){
            ServiceAddresses.clear();
        }
    }
    
    public List<ServiceAddress> getAddressRecords() {
        return ServiceAddresses;
    }
    
    public List<SelectOption> getStates() {
        List<SelectOption> States = new List<SelectOption>();
        States.add(new selectOption('NONE','-- Select One --'));
        
        List<SelectOption> States1 = new List<SelectOption>();        
        States1.add(new selectOption('AL','AL - Alabama'));
        States1.add(new selectOption('AK','AK - Alaska'));
        States1.add(new selectOption('AZ','AZ - Arizona'));
        States1.add(new selectOption('AR','AR - Arkansas'));
        States1.add(new selectOption('CA','CA - California'));
        States1.add(new selectOption('CO','CO - Colorado'));
        States1.add(new selectOption('CT','CT - Connecticut'));
        States1.add(new selectOption('DE','DE - Delaware'));
        States1.add(new selectOption('DC','DC - District of Columbia'));
        States1.add(new selectOption('FL','FL - Florida'));
        States1.add(new selectOption('GA','GA - Georgia'));
        States1.add(new selectOption('HI','HI - Hawaii'));
        States1.add(new selectOption('ID','ID - Idaho'));
        States1.add(new selectOption('IL','IL - Illinois'));
        States1.add(new selectOption('IN','IN - Indiana'));
        States1.add(new selectOption('IA','IA - Iowa'));
        States1.add(new selectOption('KS','KS - Kansas'));
        States1.add(new selectOption('KY','KY - Kentucky'));
        States1.add(new selectOption('LA','LA - Louisiana'));
        States1.add(new selectOption('ME','ME - Maine'));
        States1.add(new selectOption('MD','MD - Maryland'));
        States1.add(new selectOption('MA','MA - Massachusetts'));
        States1.add(new selectOption('MI','MI - Michigan'));
        States1.add(new selectOption('MN','MN - Minnesota'));
        States1.add(new selectOption('MS','MS - Mississippi'));
        States1.add(new selectOption('MO','MO - Missouri'));
        States1.add(new selectOption('MT','MT - Montana'));
        States1.add(new selectOption('NE','NE - Nebraska'));
        States1.add(new selectOption('NV','NV - Nevada'));
        States1.add(new selectOption('NH','NH - New Hampshire'));
        States1.add(new selectOption('NJ','NJ - New Jersey'));
        States1.add(new selectOption('NM','NM - New Mexico'));
        States1.add(new selectOption('NY','NY - New York'));
        States1.add(new selectOption('NC','NC - North Carolina'));
        States1.add(new selectOption('ND','ND - North Dakota'));
        States1.add(new selectOption('OH','OH - Ohio'));
        States1.add(new selectOption('OK','OK - Oklahoma'));
        States1.add(new selectOption('OR','OR - Oregon'));
        States1.add(new selectOption('PA','PA - Pennsylvania'));
        States1.add(new selectOption('RI','RI - Rhode Island'));
        States1.add(new selectOption('SC','SC - South Caronlina'));
        States1.add(new selectOption('SD','SD - South Dakota'));
        States1.add(new selectOption('TN','TN - Tennessee'));
        States1.add(new selectOption('TX','TX - Texas'));
        States1.add(new selectOption('UT','UT - Utah'));
        States1.add(new selectOption('VT','VT - Vermont'));
        States1.add(new selectOption('VA','VA - Virginia'));
        States1.add(new selectOption('WA','WA - Washington'));
        States1.add(new selectOption('WV','WV - West Virginia'));
        States1.add(new selectOption('WI','WI - Wisconsin'));
        States1.add(new selectOption('WY','WY - Wyoming'));
        
        return States;
    }
    
    public class ServiceAddress{
        public Integer RecordId {get;set;}      
        public WS_ESB_BusinessObjects.CitizensServiceAddress Address {get;set;}
        public List<WS_ESB_BusinessObjects.TechnologyType> Business_Technologies {get;set;}
        public List<WS_ESB_BusinessObjects.TechnologyType> Residential_Technologies {get;set;}
        public Boolean FBV_Available{get;set;} //added by vyshnavi for FBV requiremnt
        public Boolean UVerseCapable {get;set;}
        public Boolean POTSCapable {get;set;} //added the Flag for POTS availability
        
        public ServiceAddress(){
            Business_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
            Residential_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
        }
    }
    
    public class RequestedAddress {
        public String Street {get;set;}
        public String City {get;set;}
        public String StateOrProvince {get;set;}
        public String PostalCode {get;set;}
        public String Phone {get;set;}
        public String environment {get;set;}
        public String controlNumber {get;set;}
    }

    global class HughesRequest {
        public String siteId {get;set;}
        public String customerId {get;set;}
        public String servicePhone {get;set;}
        public String serviceAddress1 {get;set;}
        public String serviceAddress2 {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String hsiUpDown {get;set;}
        public String fiberUpDown {get;set;}
        public String fiberVideo {get;set;}
        public HughesRequest(){
            hsiUpDown = 'N/A';
            fiberUpDown = 'N/A';
            fiberVideo = 'N/A';
        }
    }
}