@isTest
public with sharing class ApplicationDetailFlattenerTest {
 
    @TestSetup
    static void makeData() {
        Reference_Application__c refApp = new Reference_Application__c();
        refApp.Name = 'test';
        refApp.Display_Description__c = 'testDisplayDescription';
        refApp.Display_Name__c = 'testDisplayName';
        insert refApp;

        Reference_Application_Section__c refAppSection = new Reference_Application_Section__c();
        refAppSection.Name = 'testName';
        refAppSection.Reference_Application__c = refApp.Id;
        refAppSection.Display_Section_Name__c = 'testDisplaySectionName';
        refAppSection.Sort_Order__c = 1;
        insert refAppSection;

        Reference_Application_Detail__c refAppDetail = new Reference_Application_Detail__c();  
        refAppDetail.Field_Label__c = 'test text input';
        refAppDetail.Target_Field_API_Name__c = 'Input_Text__c';
        refAppDetail.Reference_Application_Section__c = refAppSection.Id;
        refAppDetail.RecordTypeId = Schema.SObjectType.Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
            .get('Input_Text')
            .getRecordTypeId();
        refAppDetail.Sort_Order__c = 1;
        insert refAppDetail;
    }

    @isTest
    private static void SetFieldsTest() {

        Reference_Application__c refApp = [SELECT Id FROM Reference_Application__c LIMIT 1];

        Application__c app = new Application__c();
        app.Reference_Application__c = refApp.Id;
        insert app;

        Application_Detail__c detail = [SELECT Id FROM Application_Detail__c LIMIT 1];

        detail.Input_Text__c = 'ayy yoo';
        update detail;

        ApplicationDetailFlattener.Request req = new ApplicationDetailFlattener.Request();
            req.applicationId = app.Id;
            req.targetObjectRecordId = detail.Id;
        
        ApplicationDetailFlattener.SetFields(new List<ApplicationDetailFlattener.Request>{ req });

        System.assertEquals(detail.Input_Text__c, [SELECT Id, Input_Text__c FROM Application_Detail__c LIMIT 1].Input_Text__c);
    }

}