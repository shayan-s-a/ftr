@isTest
public class CBTSPayloadGeneratorTest {
    @isTest static void testCBTSPayloadGenerator() {
        Map<String, Object> output = new  Map<String, Object> ();
        Map<String, Object> options = new  Map<String, Object> ();
        Map<String, Object> temp = new Map<String, Object>();
        String method = 'generatePayload'; 
        String inputString='{"product":{"productName":"MNS - Managed Cellular Failover","productId":"MFAIL","lineItemNumber":"0001.0004"},"addressService":{"zipCode":"76932","stateCode":"Texas","cityName":"Big Lake","streetAddress":"902 North Ohio Avenue"},"SAId":"0018F00000OnboSQAR","termInMonths":"12 Months","action":"Add","quantity":1},{"product":{"productBandwidth":"500 Mbps","productName":"MNS - Managed Security - Standard","productId":"MS500","lineItemNumber":"0001.0002"},"addressService":{"zipCode":"76932","stateCode":"Texas","cityName":"Big Lake","streetAddress":"902 North Ohio Avenue"},"SAId":"0018F00000OnboSQAR","termInMonths":"12 Months","action":"Add","quantity":1},{"product":{"productBandwidth":"500 Mbps","productName":"MNS - Managed Dedicated Internet","productId":"MD500","lineItemNumber":"0001"},"addressService":{"zipCode":"76932","stateCode":"Texas","cityName":"Big Lake","streetAddress":"902 North Ohio Avenue"},"SAId":"0018F00000OnboSQAR","termInMonths":"12 Months","action":"Add","quantity":1},{"product":{"IPblock":"/29 = 5 IPs","productTopology":"Flat","productName":"IP","productId":"NA","lineItemNumber":"0001.0001"},"addressService":{"zipCode":"76932","stateCode":"Texas","cityName":"Big Lake","streetAddress":"902 North Ohio Avenue"},"SAId":"0018F00000OnboSQAR","termInMonths":"12 Months","action":"Add","quantity":1},{"product":{"productPortSpeed":"1G","productPhysicalMedium":"Copper RJ45","productBandwidth":"500 Mbps","productName":"User to Network Interface (UNI) Port","lineItemNumber":"0002"},"addressService":{"zipCode":"76932","stateCode":"Texas","cityName":"Big Lake","streetAddress":"902 North Ohio Avenue"},"SAId":"0018F00000OnboSQAR","action":"Add","quantity":1}';
        temp= (Map<String, Object>)JSON.deserializeUntyped(inputString);
        Map<String, Object> tempMap = new Map<String, Object> {
        'SAId'=> '0018F00000OnboSQAR',
          'LocationContactTN'=>  '7603296257',
          'LocationContactEmail'=>  'ejeffery@gddca.org',
          'LocationContactName'=> 'Ellen Ellen Jeffery'
        };
        List<Map<String, Object>> reqList = new List<Map<String, Object>>{tempMap};
        List<Map<String, Object>> ord = new List<Map<String, Object>>{temp};

        Map<String, Object> input = new Map<String, Object> { 
            'data' => new Map<string, object> {
                'SFOrder'=>new Map<string, object>{
                    'OrderType'=>'New Installation',
                    'LocationContact'=>reqList,
                    'SFOrderNumber'=>'10104973',
                    'SFOrderDetails'=>new Map<string, object> {
                        'OrderLineItems'=>new Map<string, object>{
                            'OrderItem'=>ord
                        }
                    
                    }
                
                }
            }
        };    
        //input = (Map<String, Object>)JSON.deserializeUntyped(input);
        Test.startTest();
        CBTSPayloadGenerator CBTS= new CBTSPayloadGenerator();
        CBTS.invokeMethod(method,input,output,options);
        Test.stopTest(); 
    }
}