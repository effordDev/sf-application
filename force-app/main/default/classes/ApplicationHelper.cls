public with sharing class ApplicationHelper {
	@AuraEnabled
	public static Application__c getApplication(Id recordId) {
		return [
			SELECT
				Id,
				Name,
				Application_Display_Name__c,
				Display_Description__c,
				Reference_Application__c,
				Status__c,
				CreatedDate,
				Read_Only__c,
				(
					SELECT
						Id,
						Name,
						Application__c,
						Reference_Application_Section__c,
						Display_Section_Label__c,
						Sort_Order__c,
						Required_Questions__c,
						Completed__c
					FROM Application_Sections__r
					ORDER BY Sort_Order__c ASC
				)
			FROM Application__c
			WHERE Id = :recordId
		];
	}

	@AuraEnabled
	public static List<Application_Language__c> getApplicationLanguages(Id applicationId){
		return [
			SELECT Id,
				Language__c,
				Reference_Application_Language__c,
				Translated_Application_Number__c,
				Translated_Display_Description__c,
				Translated_Display_Name__c,
				Translated_Status__c,
				Translated_Created_Date__c,
				Translated_Cancel_Text__c,
				Translated_Save_Text__c,
				Translated_Submit_Text__c
			FROM Application_Language__c
			WHERE Application__c = : applicationId
		];
	}

	@AuraEnabled
	public static List<Application_Section_Language__c> getApplicationSectionLanguages(Id sectionId){
		return [
			SELECT Id, 
				Language__c,
				Reference_Application_Section_Language__c,
				Translated_Display_Section_Name__c
			FROM Application_Section_Language__c
			WHERE Application_Section__c = : sectionId 
		];
	}

	@AuraEnabled
	public static List<Application_Detail__c> getApplicationDetails(
		Id applicationSectionId
	) {
		return [
			SELECT
				Id,
				Name,
				RecordTypeId,
				RecordType.DeveloperName,
				Reference_Application_Detail__c,
				Application_Section__c,
				Display_Text__c,
				Display_Rich_Text__c,
				InputOrDisplayClass__c,
				Field_Label__c,
				Required__c,
				Picklist_Values__c,
				Large_Device_Size__c,
				Medium_Device_Size__c,
				Small_Device_Size__c,
				Input_Checkbox__c,
				Input_Currency__c,
				Input_Date__c,
				Input_Datetime__c,
				Input_Number__c,
				Input_Text__c,
				Input_Text_Long__c,
				File_Rename__c,
				Accepted_File_Types__c,
				Custom_Component_JSON__c,
				Component_Name__c,
				Message_When_Pattern_Mismatch__c,
				Pattern__c,
				Minimum__c,
				Maximum__c,
				Step__c,
				Alignment__c,
				Child_sObject_API_Name__c,
				Child_sObject_Field_Set_API_Name__c,
				Child_To_Parent_Relationship_Api_Name__c,
				Child_sObject_Table_Field_Set_API_Name__c,
				Parent_Dependent_Answer__c,
				(
					SELECT Id,
						Language__c,
						Translated_Text__c,
						Application_Detail__c
					FROM Application_Detail_Languages__r
				)
				,
				(
					SELECT
					Id,
					Name,
					RecordTypeId,
					RecordType.DeveloperName,
					Reference_Application_Detail__c,
					Application_Section__c,
					Display_Text__c,
					Display_Rich_Text__c,
					InputOrDisplayClass__c,
					Field_Label__c,
					Required__c,
					Picklist_Values__c,
					Large_Device_Size__c,
					Medium_Device_Size__c,
					Small_Device_Size__c,
					Input_Checkbox__c,
					Input_Currency__c,
					Input_Date__c,
					Input_Datetime__c,
					Input_Number__c,
					Input_Text__c,
					Input_Text_Long__c,
					File_Rename__c,
					Accepted_File_Types__c,
					Custom_Component_JSON__c,
					Component_Name__c,
					Message_When_Pattern_Mismatch__c,
					Pattern__c,
					Minimum__c,
					Maximum__c,
					Step__c,
					Alignment__c,
					Child_sObject_API_Name__c,
					Child_sObject_Field_Set_API_Name__c,
					Child_To_Parent_Relationship_Api_Name__c,
					Child_sObject_Table_Field_Set_API_Name__c,
					Parent_Dependent_Answer__c
				FROM Application_Details__r
				)
			FROM Application_Detail__c
			WHERE Application_Section__c = :applicationSectionId
			AND Parent_Application_Detail__c = null
			ORDER BY Sort_Order__c ASC
		];
	}

	@AuraEnabled
	public static void saveApplicationDetails(
		Id recordId,
		Id sectionId,
		List<Application_Detail__c> details
	) {
		update details;

		List<AggregateResult> arRequiredQuestionsList = [
			SELECT Application_Section__c, COUNT(Id) RequiredQuestions
			FROM Application_Detail__c
			WHERE Application_Section__c = :sectionId 
			AND Required__c = TRUE
			AND Parent_Application_Detail__c = null
			GROUP BY Application_Section__c
		];

		List<Application_Detail__c> detailsToCheck = [
			SELECT Id, Required__c, Required_Question_Answered__c, Input_Text_Long__c 
			FROM Application_Detail__c
			WHERE Application_Section__c =: sectionId
			AND Required__c = true
		];

		Set<Id> detailIds = new Set<Id>();
		for (Application_Detail__c d : detailsToCheck) {
			if (d.Input_Text_Long__c != null || d.Required_Question_Answered__c) {
				detailIds.add(d.Id);
			}
		}

		List<AggregateResult> arRequiredQuestionsAnsweredList = [
			SELECT Application_Section__c, COUNT(Id) RequiredQuestionsAnswered
			FROM Application_Detail__c
			WHERE Application_Section__c = :sectionId
				AND Required__c = true
				// AND Required_Question_Answered__c = true
				AND Id IN : detailIds
			GROUP BY Application_Section__c
		];

		if (arRequiredQuestionsList.isEmpty()) {
			
			Application_Section__c section = new Application_Section__c();
				section.Id = sectionId;
				section.Completed__c = true;
			update section;

			Application__c app = new Application__c(
				Id = recordId,
				Status__c = 'In Progress'
			);

			update app;

			return;
		}

		AggregateResult arRequiredQuestions = arRequiredQuestionsList[0];
		AggregateResult arRequiredQuestionsAnswered = arRequiredQuestionsAnsweredList[0];

		if (
			arRequiredQuestions.get('RequiredQuestions') ==
			arRequiredQuestionsAnswered.get('RequiredQuestionsAnswered')
		) {
			Application_Section__c section = new Application_Section__c();
				section.Id = sectionId;
				section.Completed__c = true;
			update section;
		} 

		Application__c app = new Application__c(
			Id = recordId,
			Status__c = 'In Progress'
		);

		update app;
	}

	@AuraEnabled
	public static Application__c saveApplication(Application__c app) {
		update app;
		return getApplication(app.Id);
	}

	@AuraEnabled
	public static List<ContentVersion> getFiles(String recordId, String title){
		// get links
		List<ContentDocumentLink> links = [
			SELECT ContentDocumentId 
			FROM ContentDocumentLink 
			WHERE LinkedEntityId =: recordId
		];

		// get doc ids
		Set<Id> docIds = new Set<Id>();
		for(ContentDocumentLink link : links){
			docIds.add( link.ContentDocumentId );
		}

		title = title + '%';

		// get versions
		List<ContentVersion> versions = [
			SELECT Id, Title, PathOnClient, ContentDocumentId, ContentUrl,
				FileExtension, FileType, ContentSize, OwnerId, ContentModifiedDate
			FROM ContentVersion 
			WHERE ContentDocumentId IN : docIds
			AND Title LIKE : title
		];

		return versions;
	}

	@AuraEnabled
	public static void renameFiles(List<Id> contentVersionIds, String name){
		List<ContentVersion> versions = [
		    SELECT Id, Title, FileExtension
		    FROM ContentVersion 
		    WHERE Id IN : contentVersionIds
		];
  
		for (ContentVersion v : versions ) {
		    v.Title = name;
		}
  
		update versions;
	}	

	@AuraEnabled
	public static void deleteFile(Id contentDocumentId){
		// List<ContentDocument> contentDocuementsTodelete = new List<ContentDocument>(); 
  
		// for (String contentDocumentId : contentDocumentIds ) {
		// 	contentDocuementsTodelete.add(new ContentDocument(Id = contentDocumentId));
		// }
		ContentDocument cd = new ContentDocument();
			cd.Id = contentDocumentId;
		delete cd;
	}	

	@AuraEnabled
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try {
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);

            Schema.DescribeSObjectResult d = objToken.getDescribe();
			
            Map<String, Schema.FieldSet> fieldSetMap = d.fieldSets.getMap();

            if (fieldSetMap.containsKey(fieldSetName)) {
                for (Schema.FieldSetMember f : fieldSetMap.get(fieldSetName).getFields()) {

					result = String.isNotBlank(result) ? result += ',' : result;

                    String jsonPart = '{';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"label":"' + (f.getLabel()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
        } catch (Exception ex) { 
            result += ex.getLineNumber() + ' : ' + ex.getMessage();
        }
        return '['+result+']';
    }

	@AuraEnabled
	public static List<sObject> getFieldSetData(Id parentId, String sObjectName, String fieldSetName, String parentRelationship){
		system.debug('logLevel');
		system.debug(parentId);
		system.debug(sObjectName);
		system.debug(fieldSetName);
		system.debug(parentRelationship);

		String queryString = 'SELECT Id';

        List<sObject> data = new List<sObject>();

		SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);

		Schema.DescribeSObjectResult d = objToken.getDescribe();
		
		Map<String, Schema.FieldSet> fieldSetMap = d.fieldSets.getMap();

        for(Schema.FieldSetMember fld : fieldSetMap.get(fieldSetName).getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' FROM ' + sObjectName;
		queryString += ' WHERE ' + parentRelationship + ' = ' + '\''+ parentId +'\'';
		queryString +=' LIMIT 10';
         
		system.debug('queryString');
		system.debug(queryString);

        data = Database.query(queryString);
        return data;
    }
}