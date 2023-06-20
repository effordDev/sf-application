public without sharing class ApplicationTriggerHelper {
	public static void beforeInsert(List<Application__c> applications) {
		setApplicationDefaults(applications);
	}

	public static void afterInsert(List<Application__c> applications) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (Application__c application : applications) {
			referenceApplicationIds.add(application.Reference_Application__c);
		}

		Map<Id, Reference_Application__c> referenceApplicationMap = buildReferenceApplicationMap(referenceApplicationIds);

		List<Reference_Application_Section__c> referenceApplicationSections = [
			SELECT
				Id,
				Name,
				Reference_Application__c,
				Display_Section_Name__c,
				Sort_Order__c
			FROM Reference_Application_Section__c
			WHERE Reference_Application__c = : referenceApplicationMap.keySet()
		];

		Map<Id, List<Reference_Application_Section__c>> referenceApplicationSectionMap = buildReferenceApplicationSectionMap(referenceApplicationSections);

		List<Reference_Application_Detail__c> referenceApplicationDetails = [
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
				Custom_Component_JSON__c,
				Message_When_Pattern_Mismatch__c,
				Pattern__c,
				Minimum__c,
				Maximum__c,
				Step__c,
				Alignment__c,
				Child_sObject_API_Name__c,
				Child_sObject_Field_Set_API_Name__c,
				Child_To_Parent_Relationship_Api_Name__c,
				Child_sObject_Table_Field_Set_API_Name__c
			FROM Reference_Application_Detail__c
			WHERE Reference_Application_Section__c IN : referenceApplicationSections
		];

		Map<Id, List<Reference_Application_Detail__c>> referenceApplicationDetailMap = buildReferenceApplicationDetailMap(
			referenceApplicationDetails
		);
		
		List<Application_Language__c> applicationLanguageList = createApplicationLanguages(
			applications,
			referenceApplicationMap
		);

		insert applicationLanguageList;

		List<Application_Section__c> applicationSections = createAppSections(
			applications, 
			referenceApplicationMap,
			referenceApplicationSectionMap
		);

		insert applicationSections;

		List<Application_Section_Language__c> appSectionLanguagelList = createApplicationSectionLanguages(
			applicationSections,
			referenceApplicationSections
		);

		insert appSectionLanguagelList;

		List<Application_Detail__c> applicationDetails = createAppDetails(
			applicationSections, 
			referenceApplicationDetailMap
		);

		insert applicationDetails;

		List<Application_Detail_Language__c> appDetailLanguagelList = createApplicationDetaillanguages(
			applicationDetails, 
			referenceApplicationDetails
		);

		insert appDetailLanguagelList;
	}

	private static Map<Id, List<Reference_Application_Detail__c>> buildReferenceApplicationDetailMap(
		List<Reference_Application_Detail__c> referenceApplicationDetails
	) {

		Map<Id, List<Reference_Application_Detail__c>> referenceApplicationDetailMap = new Map<Id, List<Reference_Application_Detail__c>>();

		for (Reference_Application_Detail__c detail : referenceApplicationDetails) {
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
		}

		return referenceApplicationDetailMap;
	}

	private static Map<Id, List<Reference_Application_Section__c>> buildReferenceApplicationSectionMap(
		List<Reference_Application_Section__c> referenceApplicationSections
	) {

		Map<Id, List<Reference_Application_Section__c>> referenceApplicationSectionMap = new Map<Id, List<Reference_Application_Section__c>>();

		for (Reference_Application_Section__c section : referenceApplicationSections) {
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
		}

		return referenceApplicationSectionMap;
	}

	private static Map<Id, Reference_Application__c> buildReferenceApplicationMap(
		Set<Id> referenceApplicationIds
	) {
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

		return referenceApplicationMap;
	}

	private static List<Application_Section__c> createAppSections(
		List<Application__c> applications,
		Map<Id, Reference_Application__c> referenceApplicationMap,
		Map<Id, List<Reference_Application_Section__c>> referenceApplicationSectionMap
	) {

		List<Application_Section__c> applicationSections = new List<Application_Section__c>();

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

		return applicationSections;
	}

	private static List<Application_Detail__c> createAppDetails(
		List<Application_Section__c> applicationSections,
		Map<Id, List<Reference_Application_Detail__c>> referenceApplicationDetailMap
	) {

		List<Application_Detail__c> applicationDetails = new List<Application_Detail__c>();

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
				applicationDetail.Message_When_Pattern_Mismatch__c = referenceApplicationDetail.Message_When_Pattern_Mismatch__c;
				applicationDetail.Pattern__c = referenceApplicationDetail.Pattern__c;
				applicationDetail.Minimum__c = referenceApplicationDetail.Minimum__c;
				applicationDetail.Maximum__c = referenceApplicationDetail.Maximum__c;
				applicationDetail.Step__c = referenceApplicationDetail.Step__c;
				applicationDetail.Alignment__c = referenceApplicationDetail.Alignment__c;
				applicationDetail.Child_sObject_API_Name__c = referenceApplicationDetail.Child_sObject_API_Name__c;
				applicationDetail.Child_sObject_Field_Set_API_Name__c = referenceApplicationDetail.Child_sObject_Field_Set_API_Name__c;
				applicationDetail.Child_To_Parent_Relationship_Api_Name__c = referenceApplicationDetail.Child_To_Parent_Relationship_Api_Name__c;
				applicationDetail.Child_sObject_Table_Field_Set_API_Name__c = referenceApplicationDetail.Child_sObject_Table_Field_Set_API_Name__c;

				applicationDetail.RecordTypeId = Schema.SObjectType.Application_Detail__c.getRecordTypeInfosByDeveloperName()
					.get(referenceApplicationDetail.RecordType.DeveloperName)
					.getRecordTypeId();

				applicationDetails.add(applicationDetail);
			}
		}

		return applicationDetails;
	}

	private static List<Application_Language__c> createApplicationLanguages(
		List<Application__c> applications,
		Map<Id, Reference_Application__c> referenceApplicationMap
	) {

		Map<Id, List<Reference_Application_Language__c>> referenceAppLanguageMap = new Map<Id, List<Reference_Application_Language__c>>();

		for (Reference_Application_Language__c ral : [
			SELECT Id,
				Reference_Application__c,
				Translated_Application_Number__c,
				Translated_Display_Description__c,
				Translated_Display_Name__c,
				Translated_Status__c,
				Translated_Created_Date__c,
				Translated_Cancel_Text__c,
				Translated_Save_Text__c,
				Translated_Submit_Text__c
			FROM Reference_Application_Language__c
			WHERE Reference_Application__c IN : referenceApplicationMap.keySet()
		]) {

			if (referenceAppLanguageMap.containsKey(ral.Reference_Application__c)) {
				referenceAppLanguageMap.get(ral.Reference_Application__c).add(ral);
			} else {
				referenceAppLanguageMap.put(ral.Reference_Application__c, new List<Reference_Application_Language__c>{ral});
			}
		}

		List<Application_Language__c> applicationLanguages = new List<Application_Language__c>();

		for (Application__c app : applications) {

			List<Reference_Application_Language__c> ralList = referenceAppLanguageMap.get(
				app.Reference_Application__c
			);

			for (Reference_Application_Language__c ral : ralList) {

				Application_Language__c al = new Application_Language__c();

				al.Application__c = app.Id;
				al.Reference_Application_Language__c = ral.Id;
				al.Translated_Application_Number__c = ral.Translated_Application_Number__c;
				al.Translated_Display_Description__c = ral.Translated_Display_Description__c;
				al.Translated_Display_Name__c = ral.Translated_Display_Name__c;
				al.Translated_Status__c = ral.Translated_Status__c;
				al.Translated_Created_Date__c = ral.Translated_Created_Date__c;
				al.Translated_Cancel_Text__c = ral.Translated_Cancel_Text__c;
				al.Translated_Save_Text__c = ral.Translated_Save_Text__c;
				al.Translated_Submit_Text__c = ral.Translated_Submit_Text__c;
				applicationLanguages.add(al);
			}
		}
		return applicationLanguages;
	}

	private static List<Application_Section_Language__c> createApplicationSectionLanguages(
		List<Application_Section__c> appSections, 
		List<Reference_Application_Section__c> referenceApplicationSections
	) {

		Map<Id, List<Reference_Application_Section_Language__c>> referenceAppSectionLanguageMap = new Map<Id, List<Reference_Application_Section_Language__c>>();

		for (Reference_Application_Section_Language__c rasl : [
			SELECT Id,
				Reference_Application_Section__c,
				Translated_Display_Section_Name__c
			FROM Reference_Application_Section_Language__c
			WHERE Reference_Application_Section__c IN : referenceApplicationSections
		]) {

			if (referenceAppSectionLanguageMap.containsKey(rasl.Reference_Application_Section__c)) {
				referenceAppSectionLanguageMap.get(rasl.Reference_Application_Section__c).add(rasl);
			} else {
				referenceAppSectionLanguageMap.put(rasl.Reference_Application_Section__c, new List<Reference_Application_Section_Language__c>{rasl});
			}
		}

		List<Application_Section_Language__c> applicationSectionLangauges = new List<Application_Section_Language__c>();

		for (Application_Section__c appSection : appSections) {

			List <Reference_Application_Section_Language__c> raslList = referenceAppSectionLanguageMap.get(
				appSection.Reference_Application_Section__c
			);

			for (Reference_Application_Section_Language__c rasl : raslList) {

				Application_Section_Language__c asl = new Application_Section_Language__c();
				
				asl.Application_Section__c = appSection.Id;
				asl.Reference_Application_Section_Language__c = rasl.Id;
				asl.Translated_Display_Section_Name__c = rasl.Translated_Display_Section_Name__c;
				applicationSectionLangauges.add(asl);
			}
		}

		return applicationSectionLangauges;
	}

	private static List<Application_Detail_Language__c> createApplicationDetaillanguages(
		List<Application_Detail__c> appDetails, 
		List<Reference_Application_Detail__c> referenceApplicationDetails
	) {

		Map<Id, List<Reference_Application_Detail_Language__c>> referenceAppDetailLanguageMap = new Map<Id, List<Reference_Application_Detail_Language__c>>();

		for (Reference_Application_Detail_Language__c radl : [
			SELECT Id,
				Reference_Application_Detail__c,
				Translated_Text__c
			FROM Reference_Application_Detail_Language__c
			WHERE Reference_Application_Detail__c IN : referenceApplicationDetails
		]) {

			if (referenceAppDetailLanguageMap.containsKey(radl.Reference_Application_Detail__c)) {
				referenceAppDetailLanguageMap.get(radl.Reference_Application_Detail__c).add(radl);
			} else {
				referenceAppDetailLanguageMap.put(radl.Reference_Application_Detail__c, new List<Reference_Application_Detail_Language__c>{radl});
			}
		}

		List<Application_Detail_Language__c> applicationDetailLangauges = new List<Application_Detail_Language__c>();

		for (Application_Detail__c ad : appDetails) {

			List <Reference_Application_Detail_Language__c> radlList = referenceAppDetailLanguageMap.get(ad.Reference_Application_Detail__c);

			for (Reference_Application_Detail_Language__c radl : radlList) {

				Application_Detail_Language__c adl = new Application_Detail_Language__c();
				
				adl.Application_Detail__c = ad.Id;
				adl.Reference_Application_Detail_Language__c = radl.Id;
				adl.Translated_Text__c = radl.Translated_Text__c;
				applicationDetailLangauges.add(adl);
			}
		}

		return applicationDetailLangauges;
	}

	private static void setApplicationDefaults(
		List<Application__c> applications
	) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (Application__c application : applications) {
			referenceApplicationIds.add(application.Reference_Application__c);
		}

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

		for (Application__c application : applications) {
			Reference_Application__c referenceApplication = referenceApplicationMap.get(
				application.Reference_Application__c
			);

			application.Application_Display_Name__c = referenceApplication.Display_Name__c;
			application.Display_Description__c = referenceApplication.Display_Description__c;
		}
	}
}