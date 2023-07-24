public without sharing class ApplicationTriggerHelper {
	public static void beforeInsert(List<sf-Application__c> applications) {
		setApplicationDefaults(applications);
	}

	public static void afterInsert(List<sf-Application__c> applications) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (sf-Application__c application : applications) {
			referenceApplicationIds.add(application.sf_Reference_Application__c);
		}

		Map<Id, sf_Reference_Application__c> referenceApplicationMap = buildReferenceApplicationMap(referenceApplicationIds);

		List<sf_Reference_Application_Section__c> referenceApplicationSections = [
			SELECT
				Id,
				Name,
				sf_Reference_Application__c,
				Display_Section_Name__c,
				Sort_Order__c
			FROM sf_Reference_Application_Section__c
			WHERE sf_Reference_Application__c = : referenceApplicationMap.keySet()
		];

		Map<Id, List<sf_Reference_Application_Section__c>> referenceApplicationSectionMap = buildReferenceApplicationSectionMap(referenceApplicationSections);

		List<sf_Reference_Application_Detail__c> referenceApplicationDetails = [
			SELECT
				Id,
				Name,
				RecordTypeId,
				RecordType.DeveloperName,
				sf_Reference_Application_Section__c,
				Default_Value__c,	
				Field_Label__c,
				Picklist_Values__c,
				Radio_Group_Values__c,
				Checkbox_Group_Values__c,
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
				Child_sObject_Table_Field_Set_API_Name__c,
				Reference_Parent_Application_Detail__c,
				Parent_Dependent_Answer__c
			FROM sf_Reference_Application_Detail__c
			WHERE sf_Reference_Application_Section__c IN : referenceApplicationSections
			AND Reference_Parent_Application_Detail__c = null
		];

		//sectionId => List[parentDetails]
		Map<Id, List<sf_Reference_Application_Detail__c>> referenceApplicationDetailMap = buildReferenceApplicationDetailMap(
			referenceApplicationDetails
		);

		//parent detail Id => List[childDetails]
		Map<Id, List<sf_Reference_Application_Detail__c>> referenceAppParentDetailMap = buildReferenceAppParentDetailMap(referenceApplicationDetails);
		
		List<sf-Application_Language__c> applicationLanguageList = createApplicationLanguages(
			applications,
			referenceApplicationMap
		);

		if (!applicationLanguageList.isEmpty()) {
			insert applicationLanguageList;
		}

		List<sf-Application_Section__c> applicationSections = createAppSections(
			applications, 
			referenceApplicationMap,
			referenceApplicationSectionMap
		);

		if (!applicationSections.isEmpty()) {
			insert applicationSections;
		}

		List<sf-Application_Section_Language__c> appSectionLanguagelList = createApplicationSectionLanguages(
			applicationSections,
			referenceApplicationSections
		);

		if (!appSectionLanguagelList.isEmpty()) {
			insert appSectionLanguagelList;
		}

		List<sf-Application_Detail__c> applicationParentDetails = createAppParentDetails(
			applicationSections, 
			referenceApplicationDetailMap
		);

		if (!applicationParentDetails.isEmpty()) {
			insert applicationParentDetails;
		}
		
		List<sf-Application_Detail__c> applicationChildDetails = createAppChildDetails(
			applicationParentDetails,
			referenceApplicationDetailMap,
			referenceAppParentDetailMap
		);

		if (!applicationChildDetails.isEmpty()) {
			insert applicationChildDetails;
		}

		List<sf-Application_Detail_Language__c> appDetailLanguagelList = createApplicationDetaillanguages(
			applicationParentDetails, 
			referenceApplicationDetails
		);

		if (!appDetailLanguagelList.isEmpty()) {
			insert appDetailLanguagelList;
		}
	}

	private static Map<Id, List<sf_Reference_Application_Detail__c>> buildReferenceApplicationDetailMap(
		List<sf_Reference_Application_Detail__c> referenceApplicationDetails
	) {

		Map<Id, List<sf_Reference_Application_Detail__c>> referenceApplicationDetailMap = new Map<Id, List<sf_Reference_Application_Detail__c>>();

		for (sf_Reference_Application_Detail__c detail : referenceApplicationDetails) {
			if (
				referenceApplicationDetailMap.containsKey(
					detail.sf_Reference_Application_Section__c
				)
			) {
				referenceApplicationDetailMap.get(
						detail.sf_Reference_Application_Section__c
					)
					.add(detail);
			} else {
				referenceApplicationDetailMap.put(
					detail.sf_Reference_Application_Section__c,
					new List<sf_Reference_Application_Detail__c>{ detail }
				);
			}
		}

		return referenceApplicationDetailMap;
	}

	private static Map<Id, List<sf_Reference_Application_Detail__c>> buildReferenceAppParentDetailMap(
		List<sf_Reference_Application_Detail__c> referenceApplicationDetails
	) {

		Map<Id, List<sf_Reference_Application_Detail__c>> refAppParentDetailMap = new Map<Id, List<sf_Reference_Application_Detail__c>>();

		for (sf_Reference_Application_Detail__c rad : [
			SELECT Id,
				Name,
				RecordTypeId,
				RecordType.DeveloperName,
				sf_Reference_Application_Section__c,
				Field_Label__c,
				Default_Value__c,
				Picklist_Values__c,
				Radio_Group_Values__c,
				Checkbox_Group_Values__c,
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
				Child_sObject_Table_Field_Set_API_Name__c,
				Reference_Parent_Application_Detail__c,
				Parent_Dependent_Answer__c
			FROM sf_Reference_Application_Detail__c
			WHERE Reference_Parent_Application_Detail__c IN : referenceApplicationDetails
		]) {

			if (refAppParentDetailMap.containsKey(rad.Reference_Parent_Application_Detail__c)) {
				refAppParentDetailMap.get(rad.Reference_Parent_Application_Detail__c).add(rad);
			} else {
				refAppParentDetailMap.put(rad.Reference_Parent_Application_Detail__c, new List<sf_Reference_Application_Detail__c>{ rad });
			}
		}
		return refAppParentDetailMap;
	}

	private static Map<Id, List<sf_Reference_Application_Section__c>> buildReferenceApplicationSectionMap(
		List<sf_Reference_Application_Section__c> referenceApplicationSections
	) {

		Map<Id, List<sf_Reference_Application_Section__c>> referenceApplicationSectionMap = new Map<Id, List<sf_Reference_Application_Section__c>>();

		for (sf_Reference_Application_Section__c section : referenceApplicationSections) {
			if (
				referenceApplicationSectionMap.containsKey(
					section.sf_Reference_Application__c
				)
			) {
				referenceApplicationSectionMap.get(section.sf_Reference_Application__c)
					.add(section);
			} else {
				referenceApplicationSectionMap.put(
					section.sf_Reference_Application__c,
					new List<sf_Reference_Application_Section__c>{ section }
				);
			}
		}

		return referenceApplicationSectionMap;
	}

	private static Map<Id, sf_Reference_Application__c> buildReferenceApplicationMap(
		Set<Id> referenceApplicationIds
	) {
		Map<Id, sf_Reference_Application__c> referenceApplicationMap = new Map<Id, sf_Reference_Application__c>();

		for (sf_Reference_Application__c referenceApplication : [
			SELECT Id, Name, Display_Description__c, Display_Name__c
			FROM sf_Reference_Application__c
			WHERE Id = :referenceApplicationIds
		]) {
			referenceApplicationMap.put(
				referenceApplication.Id,
				referenceApplication
			);
		}

		return referenceApplicationMap;
	}

	private static List<sf-Application_Section__c> createAppSections(
		List<sf-Application__c> applications,
		Map<Id, sf_Reference_Application__c> referenceApplicationMap,
		Map<Id, List<sf_Reference_Application_Section__c>> referenceApplicationSectionMap
	) {

		List<sf-Application_Section__c> applicationSections = new List<sf-Application_Section__c>();

		for (sf-Application__c application : applications) {
			sf_Reference_Application__c referenceApplication = referenceApplicationMap.get(
				application.sf_Reference_Application__c
			);

			if (referenceApplicationMap.isEmpty()) {
				return new List<sf-Application_Section__c>();
			}

			List<sf_Reference_Application_Section__c> referenceApplicationSections = referenceApplicationSectionMap.get(
				referenceApplication.Id
			);

			if (referenceApplicationSections.isEmpty()) {
				continue;
			}

			for (
				sf_Reference_Application_Section__c referenceApplicationSection : referenceApplicationSections
			) {
				sf-Application_Section__c applicationSection = new sf-Application_Section__c();
				applicationSection.sf-Application__c = application.Id;
				applicationSection.sf_Reference_Application_Section__c = referenceApplicationSection.Id;
				applicationSection.Display_Section_Label__c = referenceApplicationSection.Display_Section_Name__c;
				applicationSection.Sort_Order__c = referenceApplicationSection.Sort_Order__c;
				applicationSections.add(applicationSection);
			}
		}

		return applicationSections;
	}

	private static List<sf-Application_Detail__c> createAppParentDetails(
		List<sf-Application_Section__c> applicationSections,
		Map<Id, List<sf_Reference_Application_Detail__c>> referenceApplicationDetailMap
	) {

		List<sf-Application_Detail__c> applicationDetails = new List<sf-Application_Detail__c>();

		for (sf-Application_Section__c applicationSection : applicationSections) {
			List<sf_Reference_Application_Detail__c> referenceApplicationDetails = referenceApplicationDetailMap.get(
				applicationSection.sf_Reference_Application_Section__c
			);

			if (referenceApplicationDetails == null) {
				continue;
			}

			for (
				sf_Reference_Application_Detail__c referenceApplicationDetail : referenceApplicationDetails
			) {
				sf-Application_Detail__c applicationDetail = new sf-Application_Detail__c();
				applicationDetail.sf-Application_Section__c = applicationSection.Id;
				applicationDetail.sf_Reference_Application_Detail__c = referenceApplicationDetail.Id;

				applicationDetail.Default_Value__c = referenceApplicationDetail.Default_Value__c;
				applicationDetail.Display_Text__c = referenceApplicationDetail.Display_Text__c;
				applicationDetail.Display_Rich_Text__c = referenceApplicationDetail.Display_Rich_Text__c;
				applicationDetail.Large_Device_Size__c = referenceApplicationDetail.Large_Device_Size__c;
				applicationDetail.Medium_Device_Size__c = referenceApplicationDetail.Medium_Device_Size__c;
				applicationDetail.Small_Device_Size__c = referenceApplicationDetail.Small_Device_Size__c;
				applicationDetail.Field_Label__c = referenceApplicationDetail.Field_Label__c;
				applicationDetail.Picklist_Values__c = referenceApplicationDetail.Picklist_Values__c;
				applicationDetail.Radio_Group_Values__c = referenceApplicationDetail.Radio_Group_Values__c;
				applicationDetail.Checkbox_Group_Values__c = referenceApplicationDetail.Checkbox_Group_Values__c;
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
				applicationDetail.Parent_Dependent_Answer__c = referenceApplicationDetail.Parent_Dependent_Answer__c;

				applicationDetail.RecordTypeId = Schema.SObjectType.sf-Application_Detail__c.getRecordTypeInfosByDeveloperName()
					.get(referenceApplicationDetail.RecordType.DeveloperName)
					.getRecordTypeId();

				applicationDetails.add(applicationDetail);
			}
		}

		return applicationDetails;
	}

	private static List<sf-Application_Detail__c> createAppChildDetails(
		List<sf-Application_Detail__c> appParentDetails,
		Map<Id, List<sf_Reference_Application_Detail__c>> referenceApplicationDetailMap,
		Map<Id, List<sf_Reference_Application_Detail__c>> referenceAppParentDetailMap
	) {

		List<sf-Application_Detail__c> childDetailsToInsert = new List<sf-Application_Detail__c>(); 

		for (sf-Application_Detail__c pd : appParentDetails) {

			if (!referenceAppParentDetailMap.containsKey(pd.sf_Reference_Application_Detail__c)) {
				continue;
			}
			List<sf_Reference_Application_Detail__c> refChildDetails = referenceAppParentDetailMap.get(pd.sf_Reference_Application_Detail__c);

			if (refChildDetails.isEmpty()) {
				continue;
			}

			for (sf_Reference_Application_Detail__c refChildDetail : refChildDetails) {

				sf-Application_Detail__c childDetail = new sf-Application_Detail__c();

					childDetail.sf-Application_Section__c = pd.sf-Application_Section__c;
					childDetail.Parent_Application_Detail__c = pd.Id;
					childDetail.sf_Reference_Application_Detail__c = refChildDetail.Id;

					childDetail.Display_Text__c = refChildDetail.Display_Text__c;
					childDetail.Default_Value__c = refChildDetail.Default_Value__c;
					childDetail.Display_Rich_Text__c = refChildDetail.Display_Rich_Text__c;
					childDetail.Large_Device_Size__c = refChildDetail.Large_Device_Size__c;
					childDetail.Medium_Device_Size__c = refChildDetail.Medium_Device_Size__c;
					childDetail.Small_Device_Size__c = refChildDetail.Small_Device_Size__c;
					childDetail.Field_Label__c = refChildDetail.Field_Label__c;
					childDetail.Picklist_Values__c = refChildDetail.Picklist_Values__c;
					childDetail.Required__c = refChildDetail.Required__c;
					childDetail.Sort_Order__c = refChildDetail.Sort_Order__c;
					childDetail.Component_Name__c = refChildDetail.Component_Name__c;
					childDetail.File_Rename__c = refChildDetail.File_Rename__c;
					childDetail.Accepted_File_Types__c = refChildDetail.Accepted_File_Types__c;
					childDetail.Custom_Component_JSON__c = refChildDetail.Custom_Component_JSON__c;
					childDetail.Message_When_Pattern_Mismatch__c = refChildDetail.Message_When_Pattern_Mismatch__c;
					childDetail.Pattern__c = refChildDetail.Pattern__c;
					childDetail.Minimum__c = refChildDetail.Minimum__c;
					childDetail.Maximum__c = refChildDetail.Maximum__c;
					childDetail.Step__c = refChildDetail.Step__c;
					childDetail.Alignment__c = refChildDetail.Alignment__c;
					childDetail.Child_sObject_API_Name__c = refChildDetail.Child_sObject_API_Name__c;
					childDetail.Child_sObject_Field_Set_API_Name__c = refChildDetail.Child_sObject_Field_Set_API_Name__c;
					childDetail.Child_To_Parent_Relationship_Api_Name__c = refChildDetail.Child_To_Parent_Relationship_Api_Name__c;
					childDetail.Child_sObject_Table_Field_Set_API_Name__c = refChildDetail.Child_sObject_Table_Field_Set_API_Name__c;

					childDetail.RecordTypeId = Schema.SObjectType.sf-Application_Detail__c.getRecordTypeInfosByDeveloperName()
						.get(refChildDetail.RecordType.DeveloperName)
						.getRecordTypeId();
	
				childDetailsToInsert.add(childDetail);
			}
		}

		return childDetailsToInsert;
	}

	private static List<sf-Application_Language__c> createApplicationLanguages(
		List<sf-Application__c> applications,
		Map<Id, sf_Reference_Application__c> referenceApplicationMap
	) {

		Map<Id, List<sf_Reference_Application_Language__c>> referenceAppLanguageMap = new Map<Id, List<sf_Reference_Application_Language__c>>();

		for (sf_Reference_Application_Language__c ral : [
			SELECT Id,
				sf_Reference_Application__c,
				Translated_Application_Number__c,
				Translated_Display_Description__c,
				Translated_Display_Name__c,
				Translated_Status__c,
				Translated_Created_Date__c,
				Translated_Cancel_Text__c,
				Translated_Save_Text__c,
				Translated_Submit_Text__c
			FROM sf_Reference_Application_Language__c
			WHERE sf_Reference_Application__c IN : referenceApplicationMap.keySet()
		]) {

			if (referenceAppLanguageMap.containsKey(ral.sf_Reference_Application__c)) {
				referenceAppLanguageMap.get(ral.sf_Reference_Application__c).add(ral);
			} else {
				referenceAppLanguageMap.put(ral.sf_Reference_Application__c, new List<sf_Reference_Application_Language__c>{ral});
			}
		}

		if (referenceAppLanguageMap.isEmpty()) {
        	return new List<sf-Application_Language__c>();
        }

		List<sf-Application_Language__c> applicationLanguages = new List<sf-Application_Language__c>();

		for (sf-Application__c app : applications) {

			List<sf_Reference_Application_Language__c> ralList = referenceAppLanguageMap.get(
				app.sf_Reference_Application__c
			);

			for (sf_Reference_Application_Language__c ral : ralList) {

				sf-Application_Language__c al = new sf-Application_Language__c();

				al.sf-Application__c = app.Id;
				al.sf_Reference_Application_Language__c = ral.Id;
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

	private static List<sf-Application_Section_Language__c> createApplicationSectionLanguages(
		List<sf-Application_Section__c> appSections, 
		List<sf_Reference_Application_Section__c> referenceApplicationSections
	) {

		Map<Id, List<sf_Reference_Application_Section_Language__c>> referenceAppSectionLanguageMap = new Map<Id, List<sf_Reference_Application_Section_Language__c>>();

		for (sf_Reference_Application_Section_Language__c rasl : [
			SELECT Id,
				sf_Reference_Application_Section__c,
				Translated_Display_Section_Name__c
			FROM sf_Reference_Application_Section_Language__c
			WHERE sf_Reference_Application_Section__c IN : referenceApplicationSections
		]) {

			if (referenceAppSectionLanguageMap.containsKey(rasl.sf_Reference_Application_Section__c)) {
				referenceAppSectionLanguageMap.get(rasl.sf_Reference_Application_Section__c).add(rasl);
			} else {
				referenceAppSectionLanguageMap.put(rasl.sf_Reference_Application_Section__c, new List<sf_Reference_Application_Section_Language__c>{rasl});
			}
		}

		if (referenceAppSectionLanguageMap.isEmpty()) {
			return new List<sf-Application_Section_Language__c>();
        }

		List<sf-Application_Section_Language__c> applicationSectionLangauges = new List<sf-Application_Section_Language__c>();

		for (sf-Application_Section__c appSection : appSections) {

			List <sf_Reference_Application_Section_Language__c> raslList = referenceAppSectionLanguageMap.get(
				appSection.sf_Reference_Application_Section__c
			);

			for (sf_Reference_Application_Section_Language__c rasl : raslList) {

				sf-Application_Section_Language__c asl = new sf-Application_Section_Language__c();
				
				asl.sf-Application_Section__c = appSection.Id;
				asl.sf_Reference_Application_Section_Language__c = rasl.Id;
				asl.Translated_Display_Section_Name__c = rasl.Translated_Display_Section_Name__c;
				applicationSectionLangauges.add(asl);
			}
		}

		return applicationSectionLangauges;
	}

	private static List<sf-Application_Detail_Language__c> createApplicationDetaillanguages(
		List<sf-Application_Detail__c> appDetails, 
		List<sf_Reference_Application_Detail__c> referenceApplicationDetails
	) {

		Map<Id, List<sf_Reference_Application_Detail_Language__c>> referenceAppDetailLanguageMap = new Map<Id, List<sf_Reference_Application_Detail_Language__c>>();

		for (sf_Reference_Application_Detail_Language__c radl : [
			SELECT Id,
				sf_Reference_Application_Detail__c,
				Translated_Text__c
			FROM sf_Reference_Application_Detail_Language__c
			WHERE sf_Reference_Application_Detail__c IN : referenceApplicationDetails
		]) {

			if (referenceAppDetailLanguageMap.containsKey(radl.sf_Reference_Application_Detail__c)) {
				referenceAppDetailLanguageMap.get(radl.sf_Reference_Application_Detail__c).add(radl);
			} else {
				referenceAppDetailLanguageMap.put(radl.sf_Reference_Application_Detail__c, new List<sf_Reference_Application_Detail_Language__c>{radl});
			}
		}

		if (referenceAppDetailLanguageMap.isEmpty()) {
			return new List<sf-Application_Detail_Language__c>();
        }

		List<sf-Application_Detail_Language__c> applicationDetailLangauges = new List<sf-Application_Detail_Language__c>();

		for (sf-Application_Detail__c ad : appDetails) {

			List <sf_Reference_Application_Detail_Language__c> radlList = referenceAppDetailLanguageMap.get(ad.sf_Reference_Application_Detail__c);

			for (sf_Reference_Application_Detail_Language__c radl : radlList) {

				sf-Application_Detail_Language__c adl = new sf-Application_Detail_Language__c();
				
				adl.sf-Application_Detail__c = ad.Id;
				adl.sf_Reference_Application_Detail_Language__c = radl.Id;
				adl.Translated_Text__c = radl.Translated_Text__c;
				applicationDetailLangauges.add(adl);
			}
		}

		return applicationDetailLangauges;
	}

	private static void setApplicationDefaults(
		List<sf-Application__c> applications
	) {
		Set<Id> referenceApplicationIds = new Set<Id>();
		for (sf-Application__c application : applications) {
			referenceApplicationIds.add(application.sf_Reference_Application__c);
		}

		Map<Id, sf_Reference_Application__c> referenceApplicationMap = new Map<Id, sf_Reference_Application__c>();
		for (sf_Reference_Application__c referenceApplication : [
			SELECT Id, Name, Display_Description__c, Display_Name__c
			FROM sf_Reference_Application__c
			WHERE Id = :referenceApplicationIds
		]) {
			referenceApplicationMap.put(
				referenceApplication.Id,
				referenceApplication
			);
		}

		for (sf-Application__c application : applications) {
			sf_Reference_Application__c referenceApplication = referenceApplicationMap.get(
				application.sf_Reference_Application__c
			);

			application.Application_Display_Name__c = referenceApplication.Display_Name__c;
			application.Display_Description__c = referenceApplication.Display_Description__c;
		}
	}
}