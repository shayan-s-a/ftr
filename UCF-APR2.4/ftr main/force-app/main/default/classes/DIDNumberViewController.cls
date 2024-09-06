public with sharing class DIDNumberViewController {

	public Boolean showSpinner { get; set; }
	public Boolean showDownload { get; set; }
	public Integer countOfDIDNumbers { get; set; }
	public ftr_DID_Location_Details__c didLocationDetails;
	public ftr_DID_Number_Details__c[] didNumbers;
	public List<ftr_DID_Number_Details__c[]> allDIDNumbers;
	public ftr_911_Option_Details__c[] x911Options;
	public Integer didNumberPageSize { get; set; }
	public Integer x911PageSize { get; set; }
    public Integer x911PageNumber { get; set; }
    public Integer didNumberPageNumber { get; set; }
	public String didLocationId { get; set; }
	public String productCode = 'SIP_TRUNKING_0010';
	public String renderAsExcel { get; set; }
	// public Map<String, Schema.SObjectField> qliLIFieldMap { get; set; }
	// public Map<String, Schema.SObjectField> product2FieldMap { get; set; }
	public class DIDNumberViewControllerException extends Exception {
	}

	public ftr_DID_Location_Details__c getDIDLocationDetails() {
		List<String> queryFields = new List<String>{
			'ServiceAccountId__r.vlocity_cmt__PremisesId__r.Premise_Detail__c',
			'Name',
			'PremisesId__r.Premise_Detail__c',
			'BTN__c',
			'TestNumber__c',
			'IncomingCallerID__c',
			'NumberOfCallPaths__c',
			'InternationalDialingOptions__c',
			'ConnectLineIDScreening__c',
			'MDN__c',
			'NumberOfDIDs__c'
		};
		return Database.query(
			'SELECT ' +
			String.join(queryFields, ', ') +
			' FROM ftr_DID_Location_Details__c WHERE Id =:didLocationId '
		);
	}
	public void setDIDLocationDetails(ftr_DID_Location_Details__c location) {
		this.didLocationDetails = location;
	}

	public ftr_DID_Number_Details__c[] getDIDNumbers() {
		List<String> queryFields = new List<String>{
			'DIDLocationDetailsId__r.ServiceAccountId__c',
			'DID_Number__c',
			'DIDNumberInfo__c',
			'Ucf_Current_Carrier__c',
			'Ucf_Install_Type__c',
			'ThirdParty__c',
			'RateCenter__c',
			'Feature__c',
			'CreatedDate',
			'CreatedBy.Name'
		};
		String baseQuery = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__c =:didLocationId ORDER BY DID_Number__c ';
		Integer offset = didNumberPageNumber * didNumberPageSize;
		String query = baseQuery + ' LIMIT '+ didNumberPageSize +' OFFSET '+ offset;
		countOfDIDNumbers = [SELECT COUNT() FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__c =:didLocationId ];
		return Database.query(query);
	}
	public void setDIDNumbers(ftr_DID_Number_Details__c[] didNumbers) {
		this.didNumbers = didNumbers;
	}

	public List<ftr_DID_Number_Details__c[]> getAllDIDNumbers() {
		List<String> queryFields = new List<String>{
			'DIDLocationDetailsId__r.ServiceAccountId__c',
			'DID_Number__c',
			'DIDNumberInfo__c',
			'Ucf_Current_Carrier__c',
			'Ucf_Install_Type__c',
			'ThirdParty__c',
			'RateCenter__c',
			'Feature__c',
			'CreatedDate',
			'CreatedBy.Name'
		};
		SObject[] records = Database.query(
			'SELECT ' +
			String.join(queryFields, ', ') +
			' FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__c =:didLocationId ORDER BY DID_Number__c LIMIT 30000 '
		);
		this.countOfDIDNumbers = records.size();
		return (List<List<ftr_DID_Number_Details__c>>) Lists.doPartions(records, 1000, List<List<ftr_DID_Number_Details__c>>.class);

	}
	public void setAllDIDNumbers(List<ftr_DID_Number_Details__c[]> didNumbers) {
		this.allDIDNumbers = didNumbers;
	}
	
	public ftr_911_Option_Details__c[] getX911Options() {
		List<String> queryFields = new List<String>{
			'Name',
			'PhoneNumber__c',
			'Option__c',
			'FTR_911_Provider__c',
			'PremisesId__r.Premise_Detail__c'
		};
		String baseQuery = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ftr_911_Option_Details__c WHERE DIDLocationDetailsId__c =:didLocationId ';
		Integer offset = x911PageNumber * x911PageSize;
		String query = baseQuery + ' LIMIT '+ x911PageSize +' OFFSET '+ offset;
		return Database.query(query);
	}
	public void setX911Options(ftr_911_Option_Details__c[] options) {
		this.x911Options = options;
	}

	public DIDNumberViewController() {
		this.showSpinner = true;
		this.didNumberPageSize = 100;
		this.x911PageSize = 10;
		this.x911PageNumber = 0;
		this.didNumberPageNumber = 0;
		this.showDownload = ApexPages.currentPage().getParameters().get('showDownloadButton') == 'false' ? false : true;
		this.didLocationId = ApexPages.currentPage().getParameters().get('didLocationId');
	}

	public class TableColumn {
		public String label { get; set; }
		public String apiName { get; set; }
		public String type { get; set; }
		public TableColumn(Map<String,Object> fieldMap) {
			this.label = (String) fieldMap.get('label');
			this.apiName = (String) fieldMap.get('apiName');
			this.type = (String) fieldMap.get('type');
		}
	}

	public PageReference generateCSV() {
		this.renderAsExcel = 'application/vnd.ms-excel#DID Number Report - ' + Datetime.now().format().replaceAll('/', '-') + '.xls';
		PageReference pdfPage = Page.DIDNumberViewCSV;
		pdfPage.getParameters().put('didLocationId', this.didLocationId);
		pdfPage.getParameters().put('renderAsExcel', this.renderAsExcel);
		pdfPage.setRedirect(false);
		return pdfPage;
	}

	public PageReference generateUcfCSV() {
		this.renderAsExcel = 'application/vnd.ms-excel#UCF Number Report - ' + Datetime.now().format().replaceAll('/', '-') + '.xls';
		PageReference pdfPage = Page.UCFNumberViewCSV;
		pdfPage.getParameters().put('didLocationId', this.didLocationId);
		pdfPage.getParameters().put('renderAsExcel', this.renderAsExcel);
		pdfPage.setRedirect(false);
		return pdfPage;
	}

	public PageReference nextNumber(){
        didNumberPageNumber++;
        this.didNumbers = getDIDNumbers();
        return null;
    }
 
    public PageReference previousNumber(){
		if (didNumberPageNumber == 0) return null;
        didNumberPageNumber--;
		this.didNumbers = getDIDNumbers();
        return null;
    }

	// public PageReference nextOption(){
    //     x911PageNumber++;
    //     getX911Options();
    //     return null;
    // }
 
    // public PageReference previousOption(){
    //     x911PageNumber--;
    //     if (x911PageNumber < 0)
    //         return null;
    //     getX911Options();
    //     return null;
    // }
}