@isTest
public with sharing class UserSignatureTest {
    
    @isTest
    public static void saveAsDocumentOnRecordTest() {

        Contact con = new Contact(
            FirstName = 'Border',
            LastName = 'Collie'
        );

        insert con;
        
        UserSignature.saveAsDocumentOnRecord(con.Id, 'BorderCollie', '.txt');
    }

    @isTest
    public static void applicationSaveAsDocumentOnRecordTest() {

        Contact con = new Contact(
            FirstName = 'Border',
            LastName = 'Collie'
        );

        insert con;
        
        UserSignature.applicationSaveAsDocumentOnRecord(con.Id, 'BorderCollie', '.txt');
        UserSignature.applicationSaveAsDocumentOnRecord(con.Id, 'BorderCollies', '.txt');
    }
}