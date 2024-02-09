public without sharing class UserSignature {
    
    @AuraEnabled
    public static void saveAsDocumentOnRecord(Id recordId, String signature, String extension){

        ContentVersion version = new ContentVersion();
        version.VersionData = EncodingUtil.base64Decode( signature );
        version.Title = 'Signature-'+System.now() +'.'+extension;
        version.PathOnClient = 'Signature-'+System.now() +'.'+extension;
        version.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        version.ContentLocation = 'S'; // S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Network

        insert version;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:version.Id].ContentDocumentId;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = recordId;
        link.ContentDocumentId = contentDocumentId;
        link.ShareType = 'I'; // V:  Viewer permission. C:  Collaborator permission. I:  Inferred permission.
        link.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
        insert link;
    }

    @AuraEnabled
    public static ContentVersion applicationSaveAsDocumentOnRecord(Id recordId, String signature, String extension){

        ContentVersion existingVersion = applicationGetSignature(recordId);

        Boolean hasExistingSignature = existingVersion.ContentDocumentId == null ? false : true;

        ContentVersion version = new ContentVersion();
            version.VersionData = EncodingUtil.base64Decode( signature );
            version.Title = 'Signature-'+ recordId +'-' + UserInfo.getUserId() + '.'+extension;
            version.Description = 'ApplicationSignature';
            version.PathOnClient = 'Signature-'+System.now() +'.'+extension;
            version.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            version.ContentLocation = 'S'; // S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Network

            if (hasExistingSignature) {
                version.ContentDocumentId = existingVersion.ContentDocumentId;
            }
        insert version;

        if (hasExistingSignature) {
            return applicationGetSignature(recordId);
        }
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:version.Id].ContentDocumentId;
        
        ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = recordId;
            link.ContentDocumentId = contentDocumentId;
            link.ShareType = 'I'; // V:  Viewer permission. C:  Collaborator permission. I:  Inferred permission.
            link.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
        insert link;

        return applicationGetSignature(recordId);
    }

    @AuraEnabled
    public static ContentVersion applicationGetSignature(Id recordId) {

        String title = 'Signature-' + recordId + '%';

        system.debug('recordId');
        system.debug(recordId);
        system.debug('title');
        system.debug(title);

        LIst<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = : recordId
        ];

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink l : links) {
            contentDocumentIds.add(l.ContentDocumentId);
        }

        List<ContentDocument> cds = [
            SELECT Id, Title
            FROM ContentDocument 
            WHERE Title LIKE : title
            AND Description = 'ApplicationSignature'
            AND Id IN : contentDocumentIds
        ];

        system.debug('cds');
        system.debug(cds);

        ContentDocument cd = new ContentDocument();

        if (cds.isEmpty()) {
            return new ContentVersion();
        }
        
        cd = cds[0];

        ContentVersion cv = [
            SELECT Id, 
                Title, 
                PathOnClient, 
                ContentUrl,
                FileExtension, 
                FileType, 
                ContentSize, 
                OwnerId, 
                ContentModifiedDate, 
                VersionData,
                VersionDataURL,
                ContentDocument.Title,
                ContentDocument.Description
            FROM ContentVersion 
            WHERE ContentDocumentId =: cd.Id
            AND isLatest = true
        ];

        return cv;
    }
}