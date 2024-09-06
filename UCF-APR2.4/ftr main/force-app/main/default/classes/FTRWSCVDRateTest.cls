/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSCVDRateTest {

    @isTest
    public static void TestFTRWSCVDRate() {
        FTRWSCVDRate cvdRate = new FTRWSCVDRate();
        cvdRate.pNUM='EIAV015ICB301402';
        cvdRate.locTier='';
        cvdRate.region='V';
        cvdRate.spec='';
    
        cvdRate.los='BASIC';
        cvdRate.vta='3';
        
        cvdRate.product='EIA';
        cvdRate.serviceTierPort='';
        cvdRate.circuitType='EVC';
        
        cvdRate.usocTier='001';
        cvdRate.usocType='';
        cvdRate.uniSpeed='';
        cvdRate.evcSpeed='2000M';
        cvdRate.nrcUsoc='EIANR';
        cvdRate.nrc='0.00';
    
        cvdRate.mrcUsoc='EIATU';
        cvdRate.mrc='1020.00';
        
        cvdRate.airlineMileageUsoc='';
        cvdRate.airlineMileageRate='';
        cvdRate.fixedMileageUsoc='';
        cvdRate.fixedMileageRate='';
        cvdRate.internetPortUsoc='';
        cvdRate.internetPortRate='';
        cvdRate.mileageThresholdUsoc='';
        cvdRate.mileageThresholdRate='';
            
        cvdRate.cntrlKey='';
           
        cvdRate.address='';
        cvdRate.city='';
        cvdRate.stateCd='';
        cvdRate.zipCd='';
        cvdRate.swc='';
        
        
    }
}

/*
//This class maps to the rate object returned in the CVD getRates rest service
public class FTRWSCVDRate {
    
    public FTRWSCVDRate() {
        
    }
    
   
}
*/