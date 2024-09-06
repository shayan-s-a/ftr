public with sharing class ftr_DPIOrderStatusEvent {
    public class Appointment {
        public String scheduleCode {get;set;} 
        public String code {get;set;} 
        public String appointmentbegin {get;set;} // in json: begin
        public String appointmentend {get;set;} // in json: end

        public Appointment(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'scheduleCode') {
                            scheduleCode = parser.getText();
                        } else if (text == 'code') {
                            code = parser.getText();
                        } else if (text == 'begin') {
                            appointmentbegin = parser.getText();
                        } else if (text == 'end') {
                            appointmentend = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Appointment consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Orders {
        public String environmentCode {get;set;} 
        public String orderNumber {get;set;} 
        public String ordertype {get;set;} // in json: type
        public Boolean isLeadOrder {get;set;} 
        public String workingTelephoneNumber {get;set;} 
        public Long usi {get;set;} 
        public String billingTelephoneNumber {get;set;} 
        public String uuid {get;set;} 
        public Appointment appointment {get;set;} 
        public Boolean isOrderCreated {get;set;} 
        public Boolean isOrderValid {get;set;} 
        public Boolean isOrderReserved {get;set;} 
        public Boolean isOrderConfirmed {get;set;} 
        public List<Messages> messages {get;set;} 

        public Orders(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'environmentCode') {
                            environmentCode = parser.getText();
                        } else if (text == 'orderNumber') {
                            orderNumber = parser.getText();
                        } else if (text == 'type') {
                            ordertype = parser.getText();
                        } else if (text == 'isLeadOrder') {
                            isLeadOrder = parser.getBooleanValue();
                        } else if (text == 'workingTelephoneNumber') {
                            workingTelephoneNumber = parser.getText();
                        } else if (text == 'usi') {
                            usi = parser.getLongValue();
                        } else if (text == 'billingTelephoneNumber') {
                            billingTelephoneNumber = parser.getText();
                        } else if (text == 'uuid') {
                            uuid = parser.getText();
                        } else if (text == 'appointment') {
                            appointment = new Appointment(parser);
                        } else if (text == 'isOrderCreated') {
                            isOrderCreated = parser.getBooleanValue();
                        } else if (text == 'isOrderValid') {
                            isOrderValid = parser.getBooleanValue();
                        } else if (text == 'isOrderReserved') {
                            isOrderReserved = parser.getBooleanValue();
                        } else if (text == 'isOrderConfirmed') {
                            isOrderConfirmed = parser.getBooleanValue();
                        } else if (text == 'messages') {
                            messages = arrayOfMessages(parser);
                            System.debug('messagelist-'+messages);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Orders consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Messages {
        public String id {get;set;} 
        public String orderFunction {get;set;} 
        public String code {get;set;} 
        public String text {get;set;} 
        public String severity {get;set;} 
        public String target {get;set;} 

        public Messages(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String textt = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (textt == 'id') {
                            id = parser.getText();
                        } else if (textt == 'orderFunction') {
                            orderFunction = parser.getText();
                        } else if (textt == 'code') {
                            code = parser.getText();
                        } else if (textt == 'text') {
                            text = parser.getText();
                            System.debug('messagetext in parser--'+text);
                        } else if (textt == 'severity') {
                            severity = parser.getText();
                        } else if (textt == 'target') {
                            target = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Messages consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public String clientTransactionId {get;set;} 
    public String transactionCount {get;set;} 
    public Boolean isOrdersCreated {get;set;} 
    public Boolean isOrdersValid {get;set;} 
    public Boolean isOrdersReserved {get;set;} 
    public Boolean isOrdersConfirmed {get;set;} 
    public AppointmentSummary appointmentSummary {get;set;} 
    public List<Orders> orders {get;set;} 

    public ftr_DPIOrderStatusEvent(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'clientTransactionId') {
                        clientTransactionId = parser.getText();
                    } else if (text == 'transactionCount') {
                        transactionCount = parser.getText();
                    } else if (text == 'isOrdersCreated') {
                        isOrdersCreated = parser.getBooleanValue();
                    } else if (text == 'isOrdersValid') {
                        isOrdersValid = parser.getBooleanValue();
                    } else if (text == 'isOrdersReserved') {
                        isOrdersReserved = parser.getBooleanValue();
                    } else if (text == 'isOrdersConfirmed') {
                        isOrdersConfirmed = parser.getBooleanValue();
                    } else if (text == 'appointmentSummary') {
                        appointmentSummary = new AppointmentSummary(parser);
                    } else if (text == 'orders') {
                        orders = arrayOfOrders(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ftr_DPIOrderStatusEvent consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class AppointmentSummary {
        public String earliestBegin {get;set;} 
        public String latestEnd {get;set;} 

        public AppointmentSummary(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'earliestBegin') {
                            earliestBegin = parser.getText();
                        } else if (text == 'latestEnd') {
                            latestEnd = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'AppointmentSummary consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static ftr_DPIOrderStatusEvent parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ftr_DPIOrderStatusEvent(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    private static List<Orders> arrayOfOrders(System.JSONParser p) {
        List<Orders> res = new List<Orders>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Orders(p));
        }
        System.debug('response array of orders-'+res);
        return res;
    }
    private static List<Messages> arrayOfMessages(System.JSONParser p) {
        System.debug('jsonparser--'+p);
        List<Messages> res = new List<Messages>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Messages(p));
        }
        System.debug('messagesresponse--'+res);
        return res;
    }

}