public with sharing class ApplicationTriggerHelper {
	public static void beforeInsert(List<Application__c> applications) {
		setApplicationDefaults(applications);
	}

	public static void afterInsert(List<Application__c> applications) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (Application__c application : applications) {
			referenceApplicationIds.add(application.Reference_Application__c);
		}

		//Reference_Application__c.Id, Reference_Application__c
		Map<Id, Reference_Application__c> referenceApplicationMap = new Map<Id, Reference_Application__c>();
		for (Reference_Application__c referenceApplication : [
			SELECT Id, Name, Display_Description__c, Display_Name__c
			FROM Reference_Application__c
			WHERE Id = :referenceApplicationIds
		]) {
			referenceApplicationMap.put(
				referenceApplication.Id,
				referenceApplication
			);
		}

		// system.debug('referenceApplicationMap');
		// system.debug(referenceApplicationMap);

		//Reference_Applicaiton__c.Id, Reference_Application_Section__c
		Map<Id, List<Reference_Application_Section__c>> referenceApplicationSectionMap = new Map<Id, List<Reference_Application_Section__c>>();
		Set<Id> referenceApplicationSectionIds = new Set<Id>();

		for (Reference_Application_Section__c section : [
			SELECT
				Id,
				Name,
				Reference_Application__c,
				Display_Section_Name__c,
				Sort_Order__c
			FROM Reference_Application_Section__c
			WHERE Reference_Application__c = :referenceApplicationMap.keySet()
		]) {
			if (
				referenceApplicationSectionMap.containsKey(
					section.Reference_Application__c
				)
			) {
				referenceApplicationSectionMap.get(section.Reference_Application__c)
					.add(section);
			} else {
				referenceApplicationSectionMap.put(
					section.Reference_Application__c,
					new List<Reference_Application_Section__c>{ section }
				);
			}
			referenceApplicationSectionIds.add(section.Id);
		}

		// system.debug('referenceApplicationSectionMap');
		// system.debug(referenceApplicationSectionMap);

		//Reference_Application_Section__c.Id, Reference_Application_Detail__c
		Map<Id, List<Reference_Application_Detail__c>> referenceApplicationDetailMap = new Map<Id, List<Reference_Application_Detail__c>>();
		Set<Id> referenceApplicationDetailIds = new Set<Id>();

		for (Reference_Application_Detail__c detail : [
			SELECT
				Id,
				Name,
				RecordTypeId,
				RecordType.DeveloperName,
				Reference_Application_Section__c,
				Field_Label__c,
				Picklist_Values__c,
				Display_Text__c,
				Display_Rich_Text__c,
				Large_Device_Size__c,
				Medium_Device_Size__c,
				Small_Device_Size__c,
				Required__c,
				Sort_Order__c,
				Component_Name__c,
				File_Rename__c,
				Accepted_File_Types__c,
				Custom_Component_JSON__c
			FROM Reference_Application_Detail__c
			WHERE Reference_Application_Section__c = :referenceApplicationSectionIds
		]) {
			if (
				referenceApplicationDetailMap.containsKey(
					detail.Reference_Application_Section__c
				)
			) {
				referenceApplicationDetailMap.get(
						detail.Reference_Application_Section__c
					)
					.add(detail);
			} else {
				referenceApplicationDetailMap.put(
					detail.Reference_Application_Section__c,
					new List<Reference_Application_Detail__c>{ detail }
				);
			}
			referenceApplicationDetailIds.add(detail.Id);
		}

		// system.debug('referenceApplicationDetailMap');
		// system.debug(referenceApplicationDetailMap);

		//create Application_Section__c's
		List<Application_Section__c> applicationSections = new List<Application_Section__c>();
		List<Application_Detail__c> applicationDetails = new List<Application_Detail__c>();

		for (Application__c application : applications) {
			Reference_Application__c referenceApplication = referenceApplicationMap.get(
				application.Reference_Application__c
			);

			List<Reference_Application_Section__c> referenceApplicationSections = referenceApplicationSectionMap.get(
				referenceApplication.Id
			);

			for (
				Reference_Application_Section__c referenceApplicationSection : referenceApplicationSections
			) {
				Application_Section__c applicationSection = new Application_Section__c();
				applicationSection.Application__c = application.Id;
				applicationSection.Reference_Application_Section__c = referenceApplicationSection.Id;
				applicationSection.Display_Section_Label__c = referenceApplicationSection.Display_Section_Name__c;
				applicationSection.Sort_Order__c = referenceApplicationSection.Sort_Order__c;
				applicationSections.add(applicationSection);
			}
		}

		insert applicationSections;

		for (Application_Section__c applicationSection : applicationSections) {
			List<Reference_Application_Detail__c> referenceApplicationDetails = referenceApplicationDetailMap.get(
				applicationSection.Reference_Application_Section__c
			);

			if (referenceApplicationDetails == null) {
				continue;
			}

			for (
				Reference_Application_Detail__c referenceApplicationDetail : referenceApplicationDetails
			) {
				Application_Detail__c applicationDetail = new Application_Detail__c();
				applicationDetail.Application_Section__c = applicationSection.Id;
				applicationDetail.Reference_Application_Detail__c = referenceApplicationDetail.Id;
				applicationDetail.Display_Text__c = referenceApplicationDetail.Display_Text__c;
				applicationDetail.Display_Rich_Text__c = referenceApplicationDetail.Display_Rich_Text__c;
				applicationDetail.Large_Device_Size__c = referenceApplicationDetail.Large_Device_Size__c;
				applicationDetail.Medium_Device_Size__c = referenceApplicationDetail.Medium_Device_Size__c;
				applicationDetail.Small_Device_Size__c = referenceApplicationDetail.Small_Device_Size__c;
				applicationDetail.Field_Label__c = referenceApplicationDetail.Field_Label__c;
				applicationDetail.Picklist_Values__c = referenceApplicationDetail.Picklist_Values__c;
				applicationDetail.Required__c = referenceApplicationDetail.Required__c;
				applicationDetail.Sort_Order__c = referenceApplicationDetail.Sort_Order__c;
				applicationDetail.Component_Name__c = referenceApplicationDetail.Component_Name__c;
				applicationDetail.File_Rename__c = referenceApplicationDetail.File_Rename__c;
				applicationDetail.Accepted_File_Types__c = referenceApplicationDetail.Accepted_File_Types__c;
				applicationDetail.Custom_Component_JSON__c = referenceApplicationDetail.Custom_Component_JSON__c;

				// system.debug('record type name');
				// system.debug(referenceApplicationDetail.RecordType.DeveloperName);

				applicationDetail.RecordTypeId = Schema.SObjectType.Application_Detail__c.getRecordTypeInfosByDeveloperName()
					.get(referenceApplicationDetail.RecordType.DeveloperName)
					.getRecordTypeId();

				applicationDetails.add(applicationDetail);
			}
		}

		insert applicationDetails;
	}

	private static void setApplicationDefaults(
		List<Application__c> applications
	) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (Application__c application : applications) {
			referenceApplicationIds.add(application.Reference_Application__c);
		}

		//Reference_Application__c.Id, Reference_Application__c
		Map<Id, Reference_Application__c> referenceApplicationMap = new Map<Id, Reference_Application__c>();
		for (Reference_Application__c referenceApplication : [
			SELECT Id, Name, Display_Description__c, Display_Name__c
			FROM Reference_Application__c
			WHERE Id = :referenceApplicationIds
		]) {
			referenceApplicationMap.put(
				referenceApplication.Id,
				referenceApplication
			);
		}

		system.debug('referenceApplicationMap');
		system.debug(referenceApplicationMap);

		for (Application__c application : applications) {
			Reference_Application__c referenceApplication = referenceApplicationMap.get(
				application.Reference_Application__c
			);

			application.Application_Display_Name__c = referenceApplication.Display_Name__c;
			application.Display_Description__c = referenceApplication.Display_Description__c;
		}
	}
}