/*** Author :Annie Naeem ***/
/*** Date : 23/12/2022 ***/
/*** Version : 1 ***/


global without sharing class ftr_SIPM6CreatePSRSystemInterface extends ftr_SIPM6BaseSystemInterface {
    public static Boolean isHolidayCheck = true;
    public static Boolean isWeekdayCheck = true;

    global class ftr_M6CreatePSRSystemInterfaceException extends Exception {}

    ftr_PSRService.createShellPsrRequestType request;
    ftr_PSRService.PSRServicePort port;
    private final static String ProductCode_UNI = 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010';
    private final static String ProductCode_EIA = 'ENT_ETH_EIA_EVC_PSR_001';
    private final static String ProductCode_EVPL = 'ENT_ETH_EVPL_EVC_PSR_001';
    /** This line of code Add by Annie for SIP product **/
    private final static String ProductCode_EVC = 'SIP_EVC_PSR_RES_SPEC_0010';
    
      public String formatTelNumber(String phoneNumber){
        if(!String.isBlank(phoneNumber)){
            String newtelNbr = phoneNumber.replaceAll('[^0-9.]', '');
              String phNumber;
               if(newtelNbr.length()!=10 && newtelNbr.startsWith('1')){
                  newtelNbr = newtelNbr.substring(1);
                }
              if(newtelNbr.length()>10) {
                  newtelNbr = newtelNbr.substring(0,10);
                }
              return newtelNbr;
          }
          else{
         return phoneNumber;               
          }
		}
        global override String getOrchestrationTaskName() {
            system.debug('Task Name returned:' + TaskName_SIPCreateShellPSR);
            return TaskName_SIPCreateShellPSR;
        }
    
    // Will get the desired due date 
    global string getDesireddueDate (string Productcode, DateTime CustomerRequestedDate ){
        DateTime DesireddueDate;
   /*     if (Productcode ==ProductCode_UNI ) {
            DesireddueDate = System.now().addDays(13);
        }
        if (Productcode ==ProductCode_EVPL ||  Productcode ==ProductCode_EIA) { 
            if (System.now().addDays(19)> CustomerRequestedDate) {
                DesireddueDate = System.now().addDays(19);
            }else {
                DesireddueDate = CustomerRequestedDate;
            }
        }*/
	  if (CustomerRequestedDate != null &&  System.now().addDays(19) > CustomerRequestedDate) {
                DesireddueDate = System.now().addDays(19);
            }else {
                DesireddueDate = CustomerRequestedDate;
            }
        DesireddueDate = getHolidayCheck(DesireddueDate);
        String newcrrDate = DesireddueDate.formatGmt('yyyy-MM-dd');
        String modifiedCRRDate = newcrrDate.replace('-', '');
        system.debug('==>modifiedCRRDate'+modifiedCRRDate);
        return modifiedCRRDate;
    }
    
    // will check Holiday
    global DateTime getHolidayCheck(DateTime DesireddueDate){
        List<Date> Holidays = new List<Date>();
        for( FTR_Holiday__mdt Holiday: [Select Date__c from FTR_Holiday__mdt]){
            Holidays.add(Holiday.Date__c);
        }
        DesireddueDate = Test.isRunningTest() ? System.today() : DesireddueDate;
        Date Desireddue = DesireddueDate.date();
        if (Holidays.contains(Desireddue)){
            DesireddueDate = DesireddueDate.addDays(1);
        }
        if (isWeekdayCheck){
            isWeekdayCheck = false;
        	DesireddueDate = getWeekdayCheck(DesireddueDate);
        }
        
        return DesireddueDate;
    }
    
     // Will check weekday 
    global DateTime getWeekdayCheck(DateTime DesireddueDate){
        String desiredDue = DesireddueDate.format('EEEE');
        if (desiredDue == 'Sunday' ){
            DesireddueDate = DesireddueDate.addDays(1);
        }
        if (desiredDue == 'Saturday' ){
            DesireddueDate = DesireddueDate.addDays(2);
        }
        if (isHolidayCheck){
            isHolidayCheck = false;
        	DesireddueDate = getHolidayCheck(DesireddueDate);
        }
        
        return DesireddueDate;
    }

    /**
     * This method is called from executeItem to create M6 RequestType 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return         M6 RequestType object to be sent
     */
    global override Object createM6RequestType(String url, String path, Map < String, Object > input) {
        this.request = new ftr_PSRService.createShellPsrRequestType();
        Map < String, Object > createPSR = (Map < String, Object > ) input.get('createShellPSR');
        Map < String, Object > PSRRequest = (Map < String, Object > ) createPSR.get('createShellPsrRequest');
        Map < String, Object > allorderContacts = (Map < String, Object > ) PSRRequest.get('orderContacts');
        List < Object > userDataList = new List < Object > ();
        Map < String, Object > userDataMap = new Map < String, Object > ();
        Map < String, Object > OrderusrData = (Map < String, Object > ) PSRRequest.get('OrderUsrData');
		System.debug('PSRRequest data '+ PSRRequest);
		System.debug('optout email value: '+ PSRRequest.get('OptOutEmail'));
        try {
            
          //Check if userData is a list or Map
           
            if (PSRRequest.get('userData') instanceof List < object > ) {
                userDataList = (List < Object > ) PSRRequest.get('userData');
            } else {
                userDataMap = (Map < String, Object > ) PSRRequest.get('userData');
            }

            // String ProdName = String.valueOf(PSRRequest.get('productName'));
            String ProdCODE = String.valueOf(PSRRequest.get('PRODUCTCODE'));
            String crrDate2 = String.valueOf(PSRRequest.get('desiredDueDate'));
            system.debug('@Touqeer'+crrDate2);
            DateTime crrDate = DateTime.valueOf(crrDate2);
            DateTime sysDate = System.now(); //fetch system date
            
            this.request.project = String.valueOf(PSRRequest.get('ProjectCodeValue'));
            if (ProdCODE ==ProductCode_UNI ) {
            this.request.desiredDueDate = getDesireddueDate (ProdCODE, crrDate);
                 system.debug('@Touqeer+danyal'+this.request.desiredDueDate);
            }
			this.request.custAcctNbr = String.valueOf(PSRRequest.get('custAcctNbr')).toUpperCase();
            system.debug('@Annie'+this.request.custAcctNbr);
            system.debug('@Annie URL'+url);
            this.request.orderedByFirstName = String.valueOf(PSRRequest.get('orderedByFirstName'));
            this.request.orderedByLastName = String.valueOf(PSRRequest.get('orderedByLastName'));
            //String telNbr = String.valueOf(PSRRequest.get('orderedByTelNbr'));
          //  String telNbr = formatTelNumber(String.valueOf(PSRRequest.get('orderedByTelNbr')));
    		String telNbr;
            if(String.valueOf(PSRRequest.get('orderedByTelNbr')) !=null){
                 telNbr = formatTelNumber(String.valueOf(PSRRequest.get('orderedByTelNbr')));
            }
            else if (String.valueOf(PSRRequest.get('insideViewTelNbr'))!=null) {
                telNbr = formatTelNumber(String.valueOf(PSRRequest.get('insideViewTelNbr')));
            }
           
            if(!String.isBlank(telNbr) && telNbr.length()==10){
         		this.request.orderedByTelNbr = telNbr;
            }

			this.request.expedite = (Boolean) PSRRequest.get('expedite');
            system.debug('request values:' + this.request.orderedByFirstName);

            //user Data
            List < ftr_PSRService.userDataType > userDataValueList = new List < ftr_PSRService.userDataType > ();
            if (userDataList.size() > 0) {
                for (Object usrVal: userDataList) {
                    Map < String, Object > usrValMap = (Map < String, Object > ) usrVal;
                    ftr_PSRService.userDataType usrValObj = new ftr_PSRService.userDataType();
                    if (usrValMap.containsKey('fieldValue') && usrValMap.get('fieldValue') != null) {
                        usrValObj.fieldName = String.valueOf(usrValMap.get('fieldName'));
                        usrValObj.fieldValue = String.valueOf(usrValMap.get('fieldValue'));
                        
                    }

                    system.debug('Setting UserData From List.');

                    //if (  !String.valueOf(usrValMap.get('fieldValue')).contains('null') && usrValObj.fieldValue!= null && !String.isBlank(usrValObj.fieldValue) && String.valueOf(usrValObj.fieldValue).length()>0){
                    // if(usrValMap.containsKey('fieldValue') && usrValMap.get('fieldValue')!=null)
                    userDataValueList.add(usrValObj);
                    system.debug('1.UserData:fieldName-->' + usrValObj.fieldName);
                    system.debug('1.UserData:fieldValue-->' + usrValObj.fieldValue);
                    // }

                }
                if (PSRRequest.get('OptOutEmail')=='Y'||PSRRequest.get('OptOutEmail')==true){
                    ftr_PSRService.userDataType usrValObj = new ftr_PSRService.userDataType();
                    usrValObj.fieldName = 'SUPRS_CUST_NOTIF';
                    usrValObj.fieldValue = '207';
                    userDataValueList.add(usrValObj);
                   System.debug('optout email value1: '+ PSRRequest.get('OptOutEmail'));
                }
            } else { // handling Data if user data is coming from Map
                ftr_PSRService.userDataType usrValObj = new ftr_PSRService.userDataType();
                if (userDataMap.containsKey('fieldValue') && userDataMap.get('fieldValue') != null) {
                    usrValObj.fieldName = String.valueOf(userDataMap.get('fieldName'));
                    usrValObj.fieldValue = String.valueOf(userDataMap.get('fieldValue'));
                    
                }
                system.debug('Setting UserData from Map.');
                     userDataValueList.add(usrValObj);
               
                system.debug('2.UserData:fieldName-->' + userDataMap.get('fieldName'));
                system.debug('2.UserData:fieldValue-->' + userDataMap.get('fieldValue'));


            }


            //adding STAT_ORDER and CONTRACT_DATE, CUST_REQ_DD
            ftr_PSRService.userDataType usrValObj1 = new ftr_PSRService.userDataType();
            usrValObj1.fieldName = String.valueOf(OrderusrData.get('StatOrder'));
            usrValObj1.fieldValue = String.valueOf(OrderusrData.get('StatsOrderVal'));
            userDataValueList.add(usrValObj1);
            usrValObj1 = new ftr_PSRService.userDataType();
            
            usrValObj1.fieldName = String.valueOf(OrderusrData.get('ContDate'));
            String contractDate = String.valueOf(OrderusrData.get('ContDateVal'));
            String modifiedContractDate = contractDate.replace('-', '');
            usrValObj1.fieldValue = modifiedContractDate;
            userDataValueList.add(usrValObj1);
            
           if (!String.isBlank(String.valueOf(OrderusrData.get('CustReqDateVal')))){
            usrValObj1 = new ftr_PSRService.userDataType();
            usrValObj1.fieldName = String.valueOf(OrderusrData.get('CustReqDate'));
            DateTime CustReqDate = DateTime.valueOf(String.valueOf(OrderusrData.get('CustReqDateVal')));
            String modifiedCustReqDateStr = CustReqDate.format('yyyy-MM-dd');
            usrValObj1.fieldValue = modifiedCustReqDateStr.replace('-', '');
            userDataValueList.add(usrValObj1);
           } 

            system.debug('userList---FINAL' + userDataValueList);
            this.request.userData = userDataValueList;

            //order contacts
            List < ftr_PSRService.contactType > contactTypeList = new List < ftr_PSRService.contactType > ();
            ftr_PSRService.contactType conTypeObj;

            //service contact
            Map < String, Object > svcContact = (Map < String, Object > ) allorderContacts.get('ServiceContact');
            if (svcContact != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(svcContact.get('contactType'));
                conTypeObj.firstName = String.valueOf(svcContact.get('firstName'));
                conTypeObj.lastName = String.valueOf(svcContact.get('lastName'));
                conTypeObj.email = String.valueOf(svcContact.get('email'));
                //String phnNbr = String.valueOf(svcContact.get('telNbr'));
                String svctelNbr = formatTelNumber(String.valueOf(svcContact.get('telNbr')));
                if(!String.isBlank(svctelNbr) && svctelNbr.length()==10){
                conTypeObj.telNbr=svctelNbr;
                }

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct ServiceContact-->');
                    contactTypeList.add(conTypeObj);
                }
            }

            //maintainence contact
            Map < String, Object > mainContact = (Map < String, Object > ) allorderContacts.get('MaintainenceContact');
            if (mainContact != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(mainContact.get('contactType'));
                conTypeObj.firstName = String.valueOf(mainContact.get('firstName'));
                conTypeObj.lastName = String.valueOf(mainContact.get('lastName'));
                conTypeObj.email = String.valueOf(mainContact.get('email'));
                //String phnNbr = String.valueOf(mainContact.get('telNbr'));
                String maintelNbr = formatTelNumber(String.valueOf(mainContact.get('telNbr')));
                if(!String.isBlank(maintelNbr) && maintelNbr.length()==10)
                conTypeObj.telNbr=maintelNbr;

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct MaintainenceContact-->');
                    contactTypeList.add(conTypeObj);
                }
            }

            //location contact
            Map < String, Object > locContact = (Map < String, Object > ) allorderContacts.get('OrderContact');
            if (locContact != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(locContact.get('contactType'));
                conTypeObj.firstName = String.valueOf(locContact.get('firstName'));
                conTypeObj.lastName = String.valueOf(locContact.get('lastName'));
                conTypeObj.email = String.valueOf(locContact.get('email'));
               // String phnNbr = String.valueOf(locContact.get('telNbr'));
                String loctelNbr = formatTelNumber(String.valueOf(locContact.get('telNbr')));
                if(!String.isBlank(loctelNbr) && loctelNbr.length()==10)
                conTypeObj.telNbr=loctelNbr;


                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct OrderContact -->');
                    contactTypeList.add(conTypeObj);
                }
            }
            Map < String, Object > projectMngr = (Map < String, Object > ) allorderContacts.get('ProjectSpecialist');
            if (projectMngr != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(projectMngr.get('contactType'));
                conTypeObj.firstName = String.valueOf(projectMngr.get('firstName')).substringBefore(' ');
                conTypeObj.lastName = String.valueOf(projectMngr.get('lastName'));
                conTypeObj.email = String.valueOf(projectMngr.get('email'));
                //String phnNbr = String.valueOf(projectMngr.get('telNbr'));
                String pmtelNbr = formatTelNumber(String.valueOf(projectMngr.get('telNbr')));
                if(!String.isBlank(pmtelNbr) && pmtelNbr.length()==10)
                conTypeObj.telNbr=pmtelNbr;

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct ProjectSpecialist Contact-->');
                    contactTypeList.add(conTypeObj);
                }
            }
            Map < String, Object > provisioner = (Map < String, Object > ) allorderContacts.get('OrderProvisioner');
            if (provisioner != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(provisioner.get('contactType'));
                conTypeObj.firstName = String.valueOf(provisioner.get('firstName')).substringBefore(' ');
                conTypeObj.lastName = String.valueOf(provisioner.get('lastName'));
                conTypeObj.email = String.valueOf(provisioner.get('email'));
                //String phnNbr = String.valueOf(provisioner.get('telNbr'));
                String pmtelNbr = formatTelNumber(String.valueOf(provisioner.get('telNbr')));
                if(!String.isBlank(pmtelNbr) && pmtelNbr.length()==10)
                conTypeObj.telNbr=pmtelNbr;

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct OrderProvisioner Contact-->');
                    contactTypeList.add(conTypeObj);
                }
            }

            Map < String, Object > SolutionEngineer = (Map < String, Object > ) allorderContacts.get('SolutionEngineer');
            if (SolutionEngineer != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(SolutionEngineer.get('contactType'));
                conTypeObj.firstName = String.valueOf(SolutionEngineer.get('firstName'));
                conTypeObj.lastName = String.valueOf(SolutionEngineer.get('lastName'));
                conTypeObj.email = String.valueOf(SolutionEngineer.get('email'));
                //String phnNbr = String.valueOf(projectMngr.get('telNbr'));
                 String solEngtelNbr = formatTelNumber(String.valueOf(SolutionEngineer.get('telNbr')));
                if(!String.isBlank(solEngtelNbr) && solEngtelNbr.length()==10)
                conTypeObj.telNbr=solEngtelNbr;

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct SE Contact-->');
                    contactTypeList.add(conTypeObj);
                }
            }

            Map < String, Object > AE = (Map < String, Object > ) allorderContacts.get('AE');
            if (AE != null) {
                conTypeObj = new ftr_PSRService.contactType();
                conTypeObj.contactType = String.valueOf(AE.get('contactType'));
                String Name = String.valueOf(AE.get('Name'));
                String[] nameSplit = Name.split('\\s');
                conTypeObj.firstName = nameSplit[0];
                if (!String.isBlank(nameSplit[1])) conTypeObj.lastName = nameSplit[1];
                system.debug('AE firstName' + conTypeObj.firstName);
                system.debug('AE lastName' + conTypeObj.lastName);
                //String phnNbr = String.valueOf(AE.get('telNbr'));
                 String AEtelNbr = formatTelNumber(String.valueOf(AE.get('telNbr')));
                if(!String.isBlank(AEtelNbr) && AEtelNbr.length()==10)
                conTypeObj.telNbr=AEtelNbr;
                system.debug('AE telNbr' + conTypeObj.telNbr);
                conTypeObj.email = String.valueOf(AE.get('Email'));

                if (!String.isBlank(conTypeObj.firstName) && !String.isBlank(conTypeObj.lastName) && !String.isBlank(conTypeObj.telNbr)) {
                    system.debug('Construct AE Contact-->');
                    contactTypeList.add(conTypeObj);
                }
            }



            this.request.orderContacts = contactTypeList;
            system.debug('Order Contacts---' + this.request.orderContacts);

            //OrderNotesArray[0]= String.valueOf(PSRRequest.get('orderNotes'));
            List < String > OrderNotesArray = new List < String > ();
            OrderNotesArray.add(String.valueOf(PSRRequest.get('orderNotes')));
            this.request.orderNotes = OrderNotesArray; //TO BE DISCUSSED

            //this.request.project = String.valueOf(PSRRequest.get('promoCodeValue'));
            system.debug('Order Notes---' + this.request.orderNotes);

        } catch (Exception ex) {
            System.debug('$$$'+ex.getStackTraceString());
            throw new ftr_M6CreatePSRSystemInterfaceException('Exception in create M6 request type' + ' : ' + ex.getMessage() + ex.getLineNumber());

        } finally {
            ftr_Logger.writeInfo('Exit ftr_M6CreatePSRSystemInterface.createM6RequestType');
        }

        return (Object) this.request;
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }



    /**
     * This method is called from executeItem to create process response
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  respType M6 ResponseType to process
     * @return         output object to be processed
     */
    global override Map < String, Object > processM6ResponseType(String url, String path, Object respType) {
        ftr_PSRService.createPsrResponseType response = (ftr_PSRService.createPsrResponseType) respType;
        Map < String, Object > documentRespMap = new Map < String, Object > ();
        system.debug('response: ' + response);

        system.debug('Code: ' + response.statusMessage.get(0).code);
        if (response.statusMessage.get(0).code != '0') {
            throw new ftr_M6SystemInterfaceException(response.statusMessage.get(0).message);
        }
        system.debug('document Number: ' + response.createPsrResult.documentNumber);
        documentRespMap.put('documentNumber', String.valueOf(response.createPsrResult.documentNumber));

        return documentRespMap;
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }


}