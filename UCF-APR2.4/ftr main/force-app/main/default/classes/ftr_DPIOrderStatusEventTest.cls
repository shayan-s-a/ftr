/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftr_DPIOrderStatusEventTest {
// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"clientTransactionId\": \"8133335122\",'+
		'  \"transactionCount\": \"3\",'+
		'  \"isOrdersCreated\": false,'+
		'  \"isOrdersValid\": false,'+
		'  \"isOrdersReserved\": false,'+
		'  \"isOrdersConfirmed\": false,'+
		'  \"appointmentSummary\": {'+
		'    \"earliestBegin\": \"0001-01-01T00:00:00-05:00\",'+
		'    \"latestEnd\": \"0001-01-01T00:00:00-05:00\"'+
		'  },'+
		'  \"orders\": ['+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756955\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": false,'+
		'      \"workingTelephoneNumber\": \"8134345132\",'+
		'      \"usi\": 670275186823,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": true,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false'+
		'    },'+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756954\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": false,'+
		'      \"workingTelephoneNumber\": \"8134345122\",'+
		'      \"usi\": 670275186807,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": true,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false'+
		'    },'+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756953\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": true,'+
		'      \"workingTelephoneNumber\": \"8133335122\",'+
		'      \"usi\": 670275186815,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": false,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false,'+
		'      \"messages\": ['+
		'        {'+
		'          \"id\": \"1006895\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E MEDAJ {Order#077756953}\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006896\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E MEDAJ\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006897\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E SSINS\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006898\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E SSINS\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006899\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E EIA2Y\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006900\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E EIA2Y\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006901\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E CKT\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006902\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E CKT\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006903\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"44049\",'+
		'          \"text\": \"Plant trait qualified.  Trait = CIRCUIT,S&E=MEDAJ,CKT\",'+
		'          \"severity\": \"INFO\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006904\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42129\",'+
		'          \"text\": \"TaxService - Tax District/Service Type combination not in SVTDD table\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006905\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42184\",'+
		'          \"text\": \"Item is not contractable: CKT\",'+
		'          \"severity\": \"ERROR\",'+
		'          \"target\": \"USER\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006906\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42184\",'+
		'          \"text\": \"Item is not contractable: EIA2Y\",'+
		'          \"severity\": \"ERROR\",'+
		'          \"target\": \"USER\"'+
		'        }'+
		'      ]'+
		'    }'+
		'  ]'+
		'}	'+
		''+
		''+
		''+
		''+
		''+
		'[10:30 AM] Gowder, Manikandan (Contr)'+
		'    '+
		'@RestResource(urlMapping=\'/KtcAccountMgt/*\')'+
		'global with sharing class MyRestResource {'+
		''+
		''+
		'    @HttpDelete'+
		'    global static void doDelete() {'+
		'        RestRequest req = RestContext.request;'+
		'        RestResponse res = RestContext.response;'+
		'        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf(\'/\')+1);'+
		'        Account account = [SELECT Id FROM Account WHERE Id = :accountId];'+
		'        delete account;'+
		'    }'+
		'  '+
		'    @HttpGet'+
		'    global static Account doGet() {'+
		'        RestRequest req = RestContext.request;'+
		'        RestResponse res = RestContext.response;'+
		'        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf(\'/\')+1);'+
		'        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];'+
		'        return result;'+
		'    }'+
		'  '+
		'  @HttpPost'+
		'    global static String doPost(String name,'+
		'        String phone, String website) {'+
		'        Account account = new Account();'+
		'        account.Name = name;'+
		'        account.phone = phone;'+
		'        account.website = website;'+
		'        insert account;'+
		'        return account.Id;'+
		'    }'+
		'}'+
		''+
		''+
		''+
		''+
		''+
		''+
		'Modified'+
		''+
		''+
		'{'+
		'  \"clientTransactionId\": \"8133335122\",'+
		'  \"transactionCount\": \"3\",'+
		'  \"isOrdersCreated\": false,'+
		'  \"isOrdersValid\": false,'+
		'  \"isOrdersReserved\": false,'+
		'  \"isOrdersConfirmed\": false,'+
		'  \"orders\": ['+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756955\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": false,'+
		'      \"workingTelephoneNumber\": \"8134345132\",'+
		'      \"usi\": 670275186823,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": true,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false'+
		'    },'+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756954\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": false,'+
		'      \"workingTelephoneNumber\": \"8134345122\",'+
		'      \"usi\": 670275186807,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": true,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false'+
		'    },'+
		'    {'+
		'      \"environmentCode\": \"FT\",'+
		'      \"orderNumber\": \"077756953\",'+
		'      \"type\": \"SI\",'+
		'      \"isLeadOrder\": true,'+
		'      \"workingTelephoneNumber\": \"8133335122\",'+
		'      \"usi\": 670275186815,'+
		'      \"billingTelephoneNumber\": \"8133335122\",'+
		'      \"uuid\": \"66E2C00115BC1A50909A0004AC1B518D\",'+
		'      \"appointment\": {'+
		'        \"scheduleCode\": \"\",'+
		'        \"code\": \" \",'+
		'        \"begin\": \"0001-01-01T00:00:00-05:00\",'+
		'        \"end\": \"0001-01-01T00:00:00-05:00\"'+
		'      },'+
		'      \"isOrderCreated\": false,'+
		'      \"isOrderValid\": false,'+
		'      \"isOrderReserved\": false,'+
		'      \"isOrderConfirmed\": false,'+
		'      \"messages\": ['+
		'        {'+
		'          \"id\": \"1006895\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006896\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006897\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E SSINS\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006898\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E SSINS\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006899\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E EIA2Y\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006900\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E EIA2Y\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006901\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.SV7NTX_TAX_FLAG for S&E CKT\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006902\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42065\",'+
		'          \"text\": \"Output only.  Field ignored.  The field is SV07.BLSEIT_SEITYP for S&E CKT\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006903\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"44049\",'+
		'          \"text\": \"Plant trait qualified.  Trait = CIRCUIT,S&E=MEDAJ,CKT\",'+
		'          \"severity\": \"INFO\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006904\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42129\",'+
		'          \"text\": \"TaxService - Tax District/Service Type combination not in SVTDD table\",'+
		'          \"severity\": \"WARN\",'+
		'          \"target\": \"SYSTEM\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006905\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42184\",'+
		'          \"text\": \"Item is not contractable: CKT\",'+
		'          \"severity\": \"ERROR\",'+
		'          \"target\": \"USER\"'+
		'        },'+
		'        {'+
		'          \"id\": \"1006906\",'+
		'          \"orderFunction\": \"CREATE\",'+
		'          \"code\": \"42184\",'+
		'          \"text\": \"Item is not contractable: EIA2Y\",'+
		'          \"severity\": \"ERROR\",'+
		'          \"target\": \"USER\"'+
		'        }'+
		'      ]'+
		'    }'+
		'  ]'+
		'}';
		ftr_DPIOrderStatusEvent r = ftr_DPIOrderStatusEvent.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ftr_DPIOrderStatusEvent.Appointment objAppointment = new ftr_DPIOrderStatusEvent.Appointment(System.JSON.createParser(json));
		System.assert(objAppointment != null);
		System.assert(objAppointment.scheduleCode == null);
		System.assert(objAppointment.code == null);
		System.assert(objAppointment.appointmentbegin == null);
		System.assert(objAppointment.appointmentend == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ftr_DPIOrderStatusEvent.Orders objOrders = new ftr_DPIOrderStatusEvent.Orders(System.JSON.createParser(json));
		System.assert(objOrders != null);
		System.assert(objOrders.environmentCode == null);
		System.assert(objOrders.orderNumber == null);
		System.assert(objOrders.ordertype == null);
		System.assert(objOrders.isLeadOrder == null);
		System.assert(objOrders.workingTelephoneNumber == null);
		System.assert(objOrders.usi == null);
		System.assert(objOrders.billingTelephoneNumber == null);
		System.assert(objOrders.uuid == null);
		System.assert(objOrders.appointment == null);
		System.assert(objOrders.isOrderCreated == null);
		System.assert(objOrders.isOrderValid == null);
		System.assert(objOrders.isOrderReserved == null);
		System.assert(objOrders.isOrderConfirmed == null);
		System.assert(objOrders.messages == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ftr_DPIOrderStatusEvent.Messages objMessages = new ftr_DPIOrderStatusEvent.Messages(System.JSON.createParser(json));
		System.assert(objMessages != null);
		System.assert(objMessages.id == null);
		System.assert(objMessages.orderFunction == null);
		System.assert(objMessages.code == null);
		System.assert(objMessages.text == null);
		System.assert(objMessages.severity == null);
		System.assert(objMessages.target == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ftr_DPIOrderStatusEvent objftr_DPIOrderStatusEvent = new ftr_DPIOrderStatusEvent(System.JSON.createParser(json));
		System.assert(objftr_DPIOrderStatusEvent != null);
		System.assert(objftr_DPIOrderStatusEvent.clientTransactionId == null);
		System.assert(objftr_DPIOrderStatusEvent.transactionCount == null);
		System.assert(objftr_DPIOrderStatusEvent.isOrdersCreated == null);
		System.assert(objftr_DPIOrderStatusEvent.isOrdersValid == null);
		System.assert(objftr_DPIOrderStatusEvent.isOrdersReserved == null);
		System.assert(objftr_DPIOrderStatusEvent.isOrdersConfirmed == null);
		System.assert(objftr_DPIOrderStatusEvent.appointmentSummary == null);
		System.assert(objftr_DPIOrderStatusEvent.orders == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ftr_DPIOrderStatusEvent.AppointmentSummary objAppointmentSummary = new ftr_DPIOrderStatusEvent.AppointmentSummary(System.JSON.createParser(json));
		System.assert(objAppointmentSummary != null);
		System.assert(objAppointmentSummary.earliestBegin == null);
		System.assert(objAppointmentSummary.latestEnd == null);
	}
}