public with sharing class ProductViewController {
	public static Map<String, String> fieldsToDisplay = new Map<String, String>{
		'Product2.Name' => 'Product Name',
		'SF_Product_Code__c' => 'Product Code',
		'SNE_DPI__c' => 'S&E DPI',
		'Part_Number__c' => 'Part Number',
		'Product2.vlocity_cmt__Type__c' => 'Sub Category',
		// 'Premise_Detail__c' => 'Service Location',
		// 'RelationshipType__c' => 'Type',
		'Quantity' => 'Quantity',
		'Type_of_Billing__c' => 'Type of Billing',
		'Unit_Price__c' => 'Unit Price',
		'vlocity_cmt__EffectiveRecurringTotal__c' => 'Total MRC',
		'vlocity_cmt__EffectiveOneTimeTotal__c' => 'Total NRC'
	};

	public Boolean showSpinner { get; set; }
	public List<TableData> allData;
	public String opportunityId { get; set; }
	public Integer totalNumberOfRecords { get; set; }
	public String renderAsExcel { get; set; }
	public Map<String, Schema.SObjectField> qliLIFieldMap { get; set; }
	public Map<String, Schema.SObjectField> product2FieldMap { get; set; }
	public class ProductViewControllerException extends Exception {
	}

	public ProductViewController() {
		this.showSpinner = true;
		this.opportunityId = ApexPages.currentPage().getParameters().get('id');
	}

	public class TableData implements Comparable {
		public String title { get; set; }
		public List<SObject> records { get; set; }
		public List<TableColumn> columns { get; set; }

		public TableData(List<QuoteLineItem> filteredItems, String title) {
			this.title = title;
			this.records = filteredItems;
			this.columns = new List<TableColumn>();
			for (String fieldName : ProductViewController.fieldsToDisplay.keySet()) {
				this.columns.add(new TableColumn(fieldName));
			}
		}

		public Integer compareTo(Object compareTo) {
			TableData obj = (TableData) compareTo;
			return this.title.compareTo(obj.title) * -1;
		}
	}

	public class TableColumn {
		public String label { get; set; }
		public String fieldName { get; set; }
		public TableColumn(String fieldName) {
			this.label = ProductViewController.fieldsToDisplay.get(fieldName);
			this.fieldName = fieldName;
		}
	}

	public void setAllData(List<TableData> lst) {
		this.allData = lst;
	}

	public List<TableData> getAllData() {
		try {
			this.allData = new List<TableData>();
			List<String> subTypeList = new List<String>{ 'Toll-Free', 'VOIP Phone' };
			Map<String, List<QuoteLineItem>> qliMap = new Map<String, List<QuoteLineItem>>();
			List<String> queryFields = new List<String>(ProductViewController.fieldsToDisplay.keySet());
			queryFields.add('Product2.vlocity_cmt__SubType__c');
			List<QuoteLineItem> qlis = Database.query(
				'SELECT ' + String.join(queryFields, ', ') +
				' FROM QuoteLineItem WHERE QuoteId IN (SELECT Id FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing__c = TRUE) AND Product2.Family = \'UCF\' '
			);
			this.totalNumberOfRecords = qlis.size();

			for (QuoteLineItem item : qlis) {
				String key;
				if (subTypeList.contains(item.Product2.vlocity_cmt__SubType__c)) {
					key = item.Product2.vlocity_cmt__SubType__c;
				} else {
					key = item.Product2.vlocity_cmt__Type__c;
				}
				if (qliMap.containsKey(key)) {
					qliMap.get(key).add(item);
				} else {
					qliMap.put(key, new List<QuoteLineItem>{ item });
				}
			}

			for (String key : qliMap.keySet()) {
				this.allData.add(new TableData((List<QuoteLineItem>) qliMap.get(key), key));
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			throw new ProductViewControllerException(e.getMessage());
		} finally {
			this.showSpinner = false;
		}

		this.allData.sort();

		return this.allData;
	}

	public PageReference generateCSV() {
		this.renderAsExcel = 'application/vnd.ms-excel#Product Report.xls';
		PageReference pdfPage = Page.ProductViewCSV;
		pdfPage.getParameters().put('id', this.opportunityId);
		pdfPage.getParameters().put('renderAsExcel', this.renderAsExcel);
		pdfPage.setRedirect(false);
		return pdfPage;
	}
}