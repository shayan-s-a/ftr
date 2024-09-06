public class WSCatalogItems implements Comparable  {
    @AuraEnabled
    public String name {get;set;}
    @AuraEnabled
    public String productName {get;set;}
    @AuraEnabled
    public String parentName {get;set;}
    
    @AuraEnabled
    public String parentId {get;set;}
    
    @AuraEnabled
    public String term {get;set;}
    
    @AuraEnabled
    public String pNum {get;set;}
    
    
    @AuraEnabled
    public String mrc {get;set;}
    @AuraEnabled
    public String nrc {get;set;}    
    @AuraEnabled
    public String mrcTotal {get;set;}
    @AuraEnabled
    public String nrcTotal {get;set;}    
    @AuraEnabled
    public String linetotal {get;set;}        
    @AuraEnabled
    public String action {get;set;}
    @AuraEnabled
    public String mrcUsoc {get;set;}    
    @AuraEnabled
    public String nrcUsoc {get;set;}
    
    @AuraEnabled
    public String uniMrcUsoc {get;set;}    
    @AuraEnabled
    public String uniNrcUsoc {get;set;}
    
    
    @AuraEnabled
    public String nniMrcUsoc {get;set;}    
    @AuraEnabled
    public String nniNrcUsoc {get;set;}
    
    
    @AuraEnabled
    public String speed {get;set;} //evcspeed
    
    
    @AuraEnabled
    public String uniSpeed {get;set;}
    
    @AuraEnabled
    public String nniSpeed {get;set;}
    
    
    @AuraEnabled
    public String qos {get;set;}
    
    
    @AuraEnabled
    public boolean disableAddToQuote {get;set;}
    
    @AuraEnabled
    public List<WSCatalogItems> children {get;set;}
    
    
    public Integer compareTo(Object obj) {
        WSCatalogItems itemObject = (WSCatalogItems)(obj);
        Double objEvcSpeed = 0;
        Double evcSpeed = 0;
        String speedClass = '';
        String objSpeedClass = ''; 
        if(itemObject.speed != null && itemObject.speed != '')   
        {
            String str = '';
            if(itemObject.speed.indexOf('M') > -1) {
                objSpeedClass = 'M';
				str = itemObject.speed.substring(0, itemObject.speed.indexOf('M'));                
            } else if(itemObject.speed.indexOf('G') > -1) {
                objSpeedClass = 'G';
                str = itemObject.speed.substring(0, itemObject.speed.indexOf('G'));                
            }
            str = str.trim();
            System.debug('Speed str:' + str);
            objEvcSpeed = Double.valueOf(str);
            
        }
        
        if(this.speed != null && this.speed != '')   
        {
            String str = '';
            if(this.speed.indexOf('M') > -1) {
                speedClass = 'M';
				str = this.speed.substring(0, this.speed.indexOf('M'));                
            } else if(this.speed.indexOf('G') > -1) {
                speedClass = 'G';
                str = this.speed.substring(0, this.speed.indexOf('G'));                
            }

            str = str.trim();
            evcSpeed = Double.valueOf(str);
            
        }
        if (FTRWSCVDController.qosArr.indexOf(this.qos) > FTRWSCVDController.qosArr.indexOf(itemObject.qos)) {
            return 1;
        } else if (FTRWSCVDController.qosArr.indexOf(this.qos) < FTRWSCVDController.qosArr.indexOf(itemObject.qos)) {
            return -1;
        } else {
            if (FTRWSCVDController.speedArr.indexOf(speedClass) > FTRWSCVDController.speedArr.indexOf(objSpeedClass)) {
                return 1;
            } else if (FTRWSCVDController.speedArr.indexOf(speedClass) < FTRWSCVDController.speedArr.indexOf(objSpeedClass)) {
                return -1;
            } else {
                if (evcSpeed > objEvcSpeed) {
            		return 1;
                } else if (evcSpeed < objEvcSpeed) {
                    return -1;
                } else {
                    return 0;
                }
            }
        }
    }
}