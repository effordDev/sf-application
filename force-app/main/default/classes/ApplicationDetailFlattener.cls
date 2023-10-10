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
            'Input_Text_Area_Long' => 'Input_Text_Long__c'
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
                Input_Text_Long__c 
            FROM Application_Detail__c 
            WHERE Application_Section__r.Application__c = : request.applicationId
                AND Target_Field_API_Name__c != null
        ];

        String targetObjectRecordId = request.targetObjectRecordId;

        String targetObjectAPIName  = (Id.valueOf(targetObjectRecordId)).getSObjectType()
            .getDescribe()
            .getName();

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(targetObjectAPIName);
        
        SObject sob = sObjectType.newSObject();
        sob.Id = targetObjectRecordId;

        system.debug('targetObjectAPIName');
        system.debug(targetObjectAPIName);
        system.debug('targetObjectRecordId');
        system.debug(targetObjectRecordId);

        for (Application_Detail__c appDetail : appDetails) {

            String sourceFieldApiName   = recordTypeInputFieldMap.get(appDetail.RecordType.DeveloperName);

            if (sourceFieldApiName == null) {
                continue;
            }

            String targetFieldApiName   = appDetail.Target_Field_API_Name__c;
            Object sourceFieldValue     = appDetail.get(sourceFieldApiName);

            system.debug(sourceFieldApiName);
            system.debug(targetFieldApiName);
            system.debug(sourceFieldValue);
            
            if (sourceFieldValue != null) {
                sob.put(targetFieldApiName, sourceFieldValue);
            }
        }

        update sob;
    }

    public class Request {
        @InvocableVariable(label='Application Id' required=true)
        public String applicationId;

        // @InvocableVariable(label='Target Object API Name' required=true)
        // public String targetObjectAPIName;

        @InvocableVariable(label='Target Object Record Id' required=true)
        public Id targetObjectRecordId;
    }
}