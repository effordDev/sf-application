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
				Input_Text_Long__c
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
		try {
			update details;

			AggregateResult arRequiredQuestions = [
				SELECT Application_Section__c, COUNT(Id) RequiredQuestions
				FROM Application_Detail__c
				WHERE Application_Section__c = :sectionId AND Required__c = TRUE
				GROUP BY Application_Section__c
			];

			AggregateResult arRequiredQuestionsAnswered = [
				SELECT Application_Section__c, COUNT(Id) RequiredQuestionsAnswered
				FROM Application_Detail__c
				WHERE
					Application_Section__c = :sectionId
					AND Required__c = TRUE
					AND Required_Question_Answered__c = TRUE
				GROUP BY Application_Section__c
			];

			// system.debug('arRequiredQuestions.get(RequiredQuestions)');
			// system.debug(arRequiredQuestions.get('RequiredQuestions'));
			// system.debug('arRequiredQuestionsAnswered.get(RequiredQuestionsAnswered');
			// system.debug(arRequiredQuestionsAnswered.get('RequiredQuestionsAnswered'));

			if (
				arRequiredQuestions.get('RequiredQuestions') ==
				arRequiredQuestionsAnswered.get('RequiredQuestionsAnswered')
			) {
				Application_Section__c section = new Application_Section__c();
				section.Id = sectionId;
				section.Completed__c = true;

				System.debug('section complete');
				update section;
			}

			Application__c app = new Application__c(
				Id = recordId,
				Status__c = 'In Progress'
			);

			update app;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Application__c saveApplication(Application__c app) {
		update app;
		return getApplication(app.Id);
	}
}
