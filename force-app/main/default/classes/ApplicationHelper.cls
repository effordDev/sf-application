public with sharing class ApplicationHelper {
	@AuraEnabled
	public static Application__c getApplication(Id recordId) {
		return [
			SELECT
				Id,
				Name,
				Application_Display_Name__c,
				Display_Description__c,
				Reference_Application__r.On_Submit_Display_Message__c,
				Status__c,
				CreatedDate,
				Read_Only__c,
				Submit_Label__c,
				Save_Label__c,
				Save_Next_Label__c,
				Application_Number_Label__c,
				Status_Label__c,
				Created_Date_Label__c,
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
				Default_Value__c,
				Display_Text__c,
				Display_Rich_Text__c,
				InputOrDisplayClass__c,
				Field_Label__c,
				Required__c,
				Picklist_Values__c,
				Radio_Group_Values__c,
				Checkbox_Group_Values__c,
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
				Flow_API_Name__c,
				Alignment__c,
				Child_sObject_API_Name__c,
				Child_sObject_Field_Set_API_Name__c,
				Child_To_Parent_Relationship_Api_Name__c,
				Child_sObject_Table_Field_Set_API_Name__c,
				Parent_Dependent_Answer__c,
				Allow_Delete__c,
				Allow_Edit__c,
				Pass_Application_Id_into_Flow__c,
				Street_Label__c,
				Province_Label__c,
				Postal_Code_Label__c,
				Country_Label__c,
				City_Label__c,
				Input_Street__c,
				Input_City__c,
				Input_State_Province__c,
				Input_Postal_Code__c,
				Input_Country__c,
				Object_Label__c,
				Object_API_Name__c,
				Primary_Search_Field_API_Name__c,
				Other_Field_API_Name__c,
				SLDS_Icon_Name__c,
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
						Default_Value__c,
						Display_Text__c,
						Display_Rich_Text__c,
						InputOrDisplayClass__c,
						Field_Label__c,
						Required__c,
						Picklist_Values__c,
						Radio_Group_Values__c,
						Checkbox_Group_Values__c,
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
						Flow_API_Name__c,
						Alignment__c,
						Child_sObject_API_Name__c,
						Child_sObject_Field_Set_API_Name__c,
						Child_To_Parent_Relationship_Api_Name__c,
						Child_sObject_Table_Field_Set_API_Name__c,
						Parent_Dependent_Answer__c,
						Allow_Delete__c,
						Allow_Edit__c,
						Pass_Application_Id_into_Flow__c,
						Street_Label__c,
						Province_Label__c,
						Postal_Code_Label__c,
						Country_Label__c,
						City_Label__c,
						Input_Street__c,
						Input_City__c,
						Input_State_Province__c,
						Input_Postal_Code__c,
						Input_Country__c,
						Object_Label__c,
						Object_API_Name__c,
						Primary_Search_Field_API_Name__c,
						Other_Field_API_Name__c,
						SLDS_Icon_Name__c
					FROM Application_Details__r
					ORDER BY Sort_Order__c ASC
				)
			FROM Application_Detail__c
			WHERE Application_Section__c = :applicationSectionId
			AND Parent_Application_Detail__c = null
			ORDER BY Sort_Order__c ASC
		];
	}

	@AuraEnabled
	public static List<Application_Detail_Language__c> getApplicationDetailLanguages(
		Id applicationSectionId
	) {
		return [
			SELECT Id,
				Language__c,
				Translated_Text__c,
				Application_Detail__c
			FROM Application_Detail_Language__c
			WHERE Application_Detail__r.Application_Section__c =: applicationSectionId
		];
	}

	@AuraEnabled
	public static void updateSobs(List<sObject> sobs){
		try {
			update sobs;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void saveApplicationDetails(
		Id recordId,
		Id sectionId,
		List<Application_Detail__c> details,
		Boolean sectionComplete
	) {
		update details;

		/* 
			removing checking if all required questions are answered as 
			front end handles 
		*/
			
		Application_Section__c section = new Application_Section__c();
			section.Id = sectionId;
			section.Completed__c = sectionComplete;
		update section;


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
                    jsonPart += '"type":"' + apexTypeToLightningType.get(String.valueof(f.getType())) + '",';
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

	public static Map<String, String> apexTypeToLightningType = new Map<String, String> {
        'ID' => 'id',
        'PHONE' => 'phone',
        'URL' => 'url',
        'EMAIL' => 'email',
        'ADDRESS' => 'text',
        'TEXTAREA' => 'text',
        'STRING' => 'text',
        'REFERENCE' => 'reference',
        'MULTIPICKLIST' => 'text',
        'PICKLIST' => 'text',
        'BOOLEAN' => 'boolean',
        'DATE' => 'date',
        'DATETIME' => 'date',
        'TIME' => 'date',
        'DOUBLE' => 'number',
        'INTEGER' => 'number',
        'CURRENCY' => 'currency',
        'PERCENT' => 'percent'
    };

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

	@AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {

			system.debug(inputWrapper);
            if(inputWrapper != null){
                String fieldsToQuery = 'SELECT Id, ';
                
				if(string.isNotBlank(inputWrapper.fieldApiName)){
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }

				system.debug(fieldsToQuery);

                if(string.isNotBlank(inputWrapper.otherFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName;
                }

				system.debug(fieldsToQuery);

                String query = fieldsToQuery + ' FROM '+ inputWrapper.objectApiName;

				system.debug(fieldsToQuery);

                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 10';
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \''+ inputWrapper.selectedRecordId + '\'';
                }else if(String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)){
                    query += ' WHERE '+ inputWrapper.parentFieldApiName+ ' = \''+ inputWrapper.parentRecordId + '\'';
                    query += ' AND ' + filterCriteria;
                } 
                else {
                    query += ' WHERE '+ filterCriteria;
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for(SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(inputWrapper.fieldApiName);
                    wrap.subField = (String)s.get(inputWrapper.otherFieldApiName);
                    wrap.id = (String)s.get('id');
                    returnWrapperList.add(wrap);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String id{get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}

		public SearchWrapper(){}
		
		public SearchWrapper(
			String p_objectApiName,
			String p_fieldApiName,
			String p_otherFieldApiName,
			String p_searchString,
			String p_selectedRecordId,
			String p_parentRecordId,
			String p_parentFieldApiName
		) {
			this.objectApiName = p_objectApiName;
			this.fieldApiName = p_fieldApiName;
			this.otherFieldApiName = p_otherFieldApiName;
			this.searchString = p_searchString;
			this.selectedRecordId = p_selectedRecordId;
			this.parentRecordId = p_parentRecordId;
			this.parentFieldApiName = p_parentFieldApiName;
		}
    }
}