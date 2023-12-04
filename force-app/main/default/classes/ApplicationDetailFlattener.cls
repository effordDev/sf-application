public without sharing class ApplicationDetailFlattener {

    @InvocableMethod(
        label='Application Detail Flattener'
        description='Takes Application Details and writes the inputted value to fields on a specified record'
    )
    public static void SetFields(List<Request> input) {

        Map<String, String> recordTypeInputFieldMap = new Map<String, String>{
            'Input_Checkbox' => 'Input_Checkbox__c',
            'Input_Checkbox_Group' => 'Input_Text__c',
            'Input_Currency' => 'Input_Currency__c',
            'Input_Date' => 'Input_Date__c',
            'Input_Date_Time' => 'Input_Datetime__c',
            'Input_Number' => 'Input_Number__c',
            'Input_Picklist' => 'Input_Text__c',
            'Input_Radio_Group' => 'Input_Text__c',
            'Input_Text' => 'Input_Text__c',
            'Input_Email' => 'Input_Text__c',
            'Input_Lookup' => 'Input_Text__c',
            'Input_Text_Area_Long' => 'Input_Text_Long__c',
            'Input_Address' => 'Input_Address'
        };

        Request request = input[0];

        List<Application_Detail__c> appDetails = [
            SELECT Id, 
                Application_Section__r.Application__c, 
                Target_Field_API_Name__c, 
                RecordType.DeveloperName, 
                Input_Checkbox__c, 
                Input_Currency__c, 
                Input_Date__c, 
                Input_Datetime__c, 
                Input_Number__c, 
                Input_Text__c, 
                Input_Text_Long__c,
                Input_Street__c,
                Input_City__c,
                Input_State_Province__c,
                Input_Postal_Code__c,
                Input_Country__c,
                Street_Target_Field_API_Name__c,
                City_Target_Field_API_Name__c,
                Province_Target_Field_API_Name__c,
                Postal_Code_Target_Field_API_Name__c,
                Country_Target_Field_API_Name__c
            FROM Application_Detail__c 
            WHERE Application_Section__r.Application__c = : request.applicationId
                AND (Target_Field_API_Name__c != null 
                OR Street_Target_Field_API_Name__c != null OR
                City_Target_Field_API_Name__c != null OR
                Province_Target_Field_API_Name__c != null OR
                Postal_Code_Target_Field_API_Name__c != null OR
                Country_Target_Field_API_Name__c != null)
            
        ];

        String targetObjectRecordId = request.targetObjectRecordId;

        String targetObjectAPIName  = (Id.valueOf(targetObjectRecordId)).getSObjectType()
            .getDescribe()
            .getName();

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(targetObjectAPIName);
        
        SObject sob = sObjectType.newSObject();
        sob.Id = targetObjectRecordId;

        system.debug('appDetails');
        system.debug(appDetails);

        for (Application_Detail__c appDetail : appDetails) {

            system.debug('appDetail.RecordType.DeveloperName');
            system.debug(appDetail.RecordType.DeveloperName);

            String sourceFieldApiName   = recordTypeInputFieldMap.get(appDetail.RecordType.DeveloperName);

            system.debug('sourceFieldApiName');
            system.debug(sourceFieldApiName);


            if (sourceFieldApiName == 'Input_Address') {
                String streetTargetFieldApiName         = appDetail.Street_Target_Field_API_Name__c;
                String cityTargetFieldApiName           = appDetail.City_Target_Field_API_Name__c;
                String provinceTargetFieldApiName       = appDetail.Province_Target_Field_API_Name__c	;
                String postalCodeTargetFieldApiName     = appDetail.Postal_Code_Target_Field_API_Name__c;
                String countryTargetFieldApiName        = appDetail.Country_Target_Field_API_Name__c	;

                if (streetTargetFieldApiName != null) {
                    sob.put(streetTargetFieldApiName, appDetail.Input_Street__c);
                }
                if (cityTargetFieldApiName != null) {
                    sob.put(cityTargetFieldApiName, appDetail.Input_City__c);
                }
                if (provinceTargetFieldApiName != null) {
                    sob.put(provinceTargetFieldApiName, appDetail.Input_State_Province__c);
                }
                if (postalCodeTargetFieldApiName != null) {
                    sob.put(postalCodeTargetFieldApiName, appDetail.Input_Postal_Code__c);
                }
                if (countryTargetFieldApiName != null) {
                    sob.put(countryTargetFieldApiName, appDetail.Input_Country__c);
                }

            } else if (sourceFieldApiName != null) {
                String targetFieldApiName   = appDetail.Target_Field_API_Name__c;
                Object sourceFieldValue     = appDetail.get(sourceFieldApiName);
                
                if (sourceFieldValue != null) {
                    sob.put(targetFieldApiName, sourceFieldValue);
                }
            }

            system.debug('sob');
            system.debug(sob);
        }

        update sob;
    }

    public class Request {
        @InvocableVariable(label='Application Id' required=true)
        public String applicationId;

        @InvocableVariable(label='Target Object Record Id' required=true)
        public Id targetObjectRecordId;
    }
}
/* 
ApplicationDetailFlattener.Request req = new ApplicationDetailFlattener.Request();
List<ApplicationDetailFlattener.Request> reqList = new List<ApplicationDetailFlattener.Request>();

req.applicationId = 'a05DE00000L1ulzYAB';
req.targetObjectRecordId = '001DE000039YX2SYAW';

reqList.add(req);
ApplicationDetailFlattener.setFields(reqList);
*/