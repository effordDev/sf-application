@isTest
public with sharing class ApplicationHelperTest {
    
    @TestSetup
    static void makeData(){
        
        sf_Reference_Application__c refApp = new sf_Reference_Application__c();
        refApp.Name = 'test';
        refApp.Display_Description__c = 'testDisplayDescription';
        refApp.Display_Name__c = 'testDisplayName';
        insert refApp;

        sf_Reference_Application_Section__c refAppSection = new sf_Reference_Application_Section__c();
        refAppSection.Name = 'testName';
        refAppSection.sf_Reference_Application__c = refApp.Id;
        refAppSection.Display_Section_Name__c = 'testDisplaySectionName';
        refAppSection.Sort_Order__c = 1;
        insert refAppSection;

        sf_Reference_Application_Section__c refAppSection2 = new sf_Reference_Application_Section__c();
        refAppSection2.Name = 'testName2';
        refAppSection2.sf_Reference_Application__c = refApp.Id;
        refAppSection2.Display_Section_Name__c = 'testDisplaySectionName2';
        refAppSection2.Sort_Order__c = 2;
        insert refAppSection2;

        sf_Reference_Application_Detail__c refAppDetail = new sf_Reference_Application_Detail__c();  
        refAppDetail.Field_Label__c = 'test text input';
        refAppDetail.sf_Reference_Application_Section__c = refAppSection.Id;
        refAppDetail.RecordTypeId = Schema.SObjectType.sf_Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
        .get('Input_Text')
        .getRecordTypeId();
        refAppDetail.Sort_Order__c = 1;
        insert refAppDetail;

        sf_Reference_Application_Detail__c refAppDetailPicklist = new sf_Reference_Application_Detail__c();  
        refAppDetailPicklist.Field_Label__c = 'test picklist input';
        refAppDetailPicklist.sf_Reference_Application_Section__c = refAppSection.Id;
        refAppDetailPicklist.Picklist_Values__c = 'Yes;No';
        refAppDetailPicklist.Parent_Dependent_Answer__c = 'Yes';
        refAppDetailPicklist.RecordTypeId = Schema.SObjectType.sf_Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
        .get('Input_Picklist')
        .getRecordTypeId();
        refAppDetailPicklist.Sort_Order__c = 2;
        insert refAppDetailPicklist;

        sf_Reference_Application_Detail__c refAppDetailPicklistChild = new sf_Reference_Application_Detail__c();  
        refAppDetailPicklistChild.Field_Label__c = 'test picklist input Child';
        refAppDetailPicklistChild.sf_Reference_Application_Section__c = refAppSection.Id;
        refAppDetailPicklistChild.Reference_Parent_Application_Detail__c = refAppDetailPicklist.Id;
        refAppDetailPicklistChild.Picklist_Values__c = 'Yes;No';
        refAppDetailPicklistChild.RecordTypeId = Schema.SObjectType.sf_Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
        .get('Input_Picklist')
        .getRecordTypeId();
        refAppDetailPicklistChild.Sort_Order__c = 3;
        insert refAppDetailPicklistChild;

        sf_Reference_Application_Detail__c refAppDetail2 = new sf_Reference_Application_Detail__c();  
        refAppDetail2.Field_Label__c = 'test text input';
        refAppDetail2.sf_Reference_Application_Section__c = refAppSection2.Id;
        refAppDetail2.RecordTypeId = Schema.SObjectType.sf_Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
        .get('Input_Text')
        .getRecordTypeId();
        refAppDetail2.Sort_Order__c = 4;
        insert refAppDetail2;

        sf_Reference_Application_Detail__c refAppDetailRequired = new sf_Reference_Application_Detail__c();  
        refAppDetailRequired.Field_Label__c = 'test text input';
        refAppDetailRequired.sf_Reference_Application_Section__c = refAppSection.Id;
        refAppDetailRequired.RecordTypeId = Schema.SObjectType.sf_Reference_Application_Detail__c.getRecordTypeInfosByDeveloperName()
        .get('Input_Text')
        .getRecordTypeId();
        refAppDetailRequired.Sort_Order__c = 5;
        refAppDetailRequired.Required__c = true;
        insert refAppDetailRequired;
    }

    @isTest
    private static void getFieldSetTest(){
        ApplicationHelper.getFieldSet('sf_Reference_Application_Detail__c', 'App_Details');
    }
    
    @isTest
    private static void setApplicationDefaultsTest() {

        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;
    }

    @isTest
    private static void getApplicationTest() {

        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        ApplicationHelper.getApplication(app.Id);
    }

    @isTest 
    private static void getApplicationLanguagesTest() {
        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        ApplicationHelper.getApplicationLanguages(app.Id);
    }

    @isTest 
    private static void getApplicationSectionLanguagesTest() {
        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        ApplicationHelper.getApplicationSectionLanguages([
            SELECT Id 
            FROM sf_Application_Section__c 
            WHERE sf_Application__c =: app.Id 
            LIMIT 1].Id
        );
    }

    @isTest
    private static void getApplicationDetailsTest() {

        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        sf_Application_Section__c appSection = [
            SELECT Id
            FROM sf_Application_Section__c 
            WHERE sf_Application__c = : app.Id
            LIMIT 1
        ];

        ApplicationHelper.getApplicationDetails(appSection.Id);
    }

    @isTest
    private static void saveApplicationRequiredDetailsTest() {

        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        sf_Application_Section__c appSection = [
            SELECT Id
            FROM sf_Application_Section__c 
            WHERE sf_Application__c = : app.Id
            AND Display_Section_Label__c = 'testDisplaySectionName'
            LIMIT 1
        ];

        sf_Application_Detail__c appDetail = [
            SELECT Id
            FROM sf_Application_Detail__c 
            WHERE sf_Application_Section__c = : appSection.Id
            AND Required__c = true
            LIMIT 1
        ];

        appDetail.Input_Text__c = 'inputedtext';

        List<sf_Application_Detail__c> appDetails = new List<sf_Application_Detail__c>();
        appDetails.add(appDetail);

        ApplicationHelper.saveApplicationDetails(
            app.Id,    
            appSection.Id,    
            appDetails
        );
    }

    @isTest
    private static void saveApplicationNonRequiredDetailsTest() {

        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        sf_Application_Section__c appSection = [
            SELECT Id
            FROM sf_Application_Section__c 
            WHERE sf_Application__c = : app.Id
            AND Display_Section_Label__c = 'testDisplaySectionName2'
            LIMIT 1
        ];

        sf_Application_Detail__c appDetail = [
            SELECT Id
            FROM sf_Application_Detail__c 
            WHERE sf_Application_Section__c = : appSection.Id
            LIMIT 1
        ];

        appDetail.Input_Text__c = 'inputedtext';

        List<sf_Application_Detail__c> appDetails = new List<sf_Application_Detail__c>();
        appDetails.add(appDetail);

        ApplicationHelper.saveApplicationDetails(
            app.Id,    
            appSection.Id,    
            appDetails
        );
    }

    @isTest
    private static void saveApplicationTest() {
        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        app.Status__c = 'Submitted';
        ApplicationHelper.saveApplication(app);
    }

    @isTest
    private static void filesTest() {
        sf_Reference_Application__c refApp = [SELECT Id FROM sf_Reference_Application__c LIMIT 1];

        sf_Application__c app = new sf_Application__c();
        app.sf_Reference_Application__c = refApp.Id;
        insert app;

        ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Cat';
            contentVersion.PathOnClient = 'meow.jpg';
            contentVersion.VersionData = Blob.valueOf('I am Cat');
            contentVersion.IsMajorVersion = true;
        insert contentVersion; 

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = app.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
        insert cdl;

        List<ContentVersion> files = ApplicationHelper.getFiles(app.Id, 'Cat');

        List<Id> cvids = new List<Id>{files[0].Id};

        ApplicationHelper.renameFiles(cvids, 'test');
        ApplicationHelper.deleteFile(files[0].ContentDocumentId);
    }
}