public with sharing class ApplicationHelper {
	@AuraEnabled
	public static Application__c getApplication(Id recordId) {
		try {
			return [
				SELECT
					Id,
					Name,
					Application_Display_Name__c,
					Display_Description__c,
					Reference_Application__c,
					Status__c,
					CreatedDate,
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
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
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
				Custom_Component_JSON__c
			FROM Application_Detail__c
			WHERE Application_Section__c = :applicationSectionId
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
			GROUP BY Application_Section__c
		];

		List<AggregateResult> arRequiredQuestionsAnsweredList = [
			SELECT Application_Section__c, COUNT(Id) RequiredQuestionsAnswered
			FROM Application_Detail__c
			WHERE Application_Section__c = :sectionId
				AND Required__c = TRUE
				AND Required_Question_Answered__c = TRUE
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
}