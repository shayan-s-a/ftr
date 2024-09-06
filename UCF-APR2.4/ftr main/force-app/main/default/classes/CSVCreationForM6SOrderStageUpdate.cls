public with sharing class CSVCreationForM6SOrderStageUpdate {
    public static void createCsv(Map<String, String> sOrder, String fileFlag){

        String csvColumnHeader;
        List<String> csvRowValues = new List<String>();
        String parentId;
        String fileName = '';
        String msgSubject = '';

        for(String item: sOrder.keyset()) {
            String eachRow = item + ',' + sOrder.get(item);
            csvRowValues.add(eachRow);
        }


        if(fileFlag == 'Updated') {
            fileName = 'ServiceOrderListUpdated.csv';
            msgSubject = 'Updated list of Service Orders.';
        } else if (fileFlag == 'Not Updated') {
            fileName = 'ServiceOrderListNotUpdated.csv';
            msgSubject = 'Not Updated list of Service Orders.';
        } else {
            fileName = 'ServiceOrderListWithExceptions.csv';
            msgSubject = 'List of Service Orders with exceptions';
        }

        csvColumnHeader = 'Service order Id, Service order #\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        System.debug(csvFile);

        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        blob b = Blob.valueOf(csvFile);


        attach1.setFileName(fileName);
        attach1.setBody(b);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attach1});
        String[] toAddresses = new String[] {'ykhan@aprosoft.com'};
        message.setToAddresses(toAddresses);
        message.setSubject(msgSubject);
        message.setHtmlBody('Please check on the attached csv file ');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });

    }
}