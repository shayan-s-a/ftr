/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class ftr_LoggerTest {
    @isTest  
    static void writeTest() {
        String Message = 'Exception Found';
        ftr_Logger.write(Message);
       
    }
    @isTest  
    static void writeErrTest() {
        String Message = 'Exception Found';
        ftr_Logger.writeErr(Message);
       
    }
    @isTest  
    static void writeInfoTest() {
        String Message = 'Exception Found';
        ftr_Logger.writeInfo(Message);
       
    }
    @isTest  
    static void writeFineTest() {
        String Message = 'Exception Found';
        ftr_Logger.writeFine(Message);
       
    } 
    @isTest  
    static void writeTest2() {
        Exception e =new DMLException('My DML EXCEPTION'); 
        ftr_Logger.write(e);       
    }
    @isTest  
    static void writeVarTest() {
        String Message = 'Exception Found';
        Object val = 'Test';
        ftr_Logger.writeVar(Message, val);
       
    } 
}