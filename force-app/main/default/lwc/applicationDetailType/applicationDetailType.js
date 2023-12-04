import { api, LightningElement } from "lwc";
export default class ApplicationDetailType extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api languages = [];
	@api detail = {};
	@api isSectionComplete = false;
	@api isCommunity = false

	@api isValid() {
		// console.log(this.refs)
		return this.refs.input?.completed;
	}

	errorCallback(error, stack) {
		console.log("error");
		console.log(error?.message);
		console.log(stack);
	}

	get recordTypeName() {
		return this.detail?.RecordType?.DeveloperName;
	}

	get inputDisplayClass() {
		return this.recordTypeName.includes("Input")
			? "customInput"
			: "customDisplay";
	}

	get isDisplayText() {
		return this.recordTypeName === "Display_Text";
	}
	get isDisplayRichText() {
		return this.recordTypeName === "Display_Rich_Text";
	}
	get isInputTextAreaLong() {
		return this.recordTypeName === "Input_Text_Area_Long";
	}
	get isInputText() {
		return this.recordTypeName === "Input_Text";
	}
	get isInputAddress() {
		return this.recordTypeName === "Input_Address";
	}
	get isInputEmail() {
		return this.recordTypeName === "Input_Email";
	}
	get isInputNumber() {
		return this.recordTypeName === "Input_Number";
	}
	get isInputCurrency() {
		return this.recordTypeName === "Input_Currency";
	}
	get isInputCheckbox() {
		return this.recordTypeName === "Input_Checkbox";
	}
	get isInputPicklist() {
		return this.recordTypeName === "Input_Picklist";
	}
	get isInputRadioGroup() {
		return this.recordTypeName === "Input_Radio_Group";
	}
	get isInputCheckboxGroup() {
		return this.recordTypeName === "Input_Checkbox_Group";
	}
	get isInputDate() {
		return this.recordTypeName === "Input_Date";
	}
	get isInputDateTime() {
		return this.recordTypeName === "Input_Date_Time";
	}
	get isInputFile() {
		return this.recordTypeName === "Input_File";
	}
	get isInputRecordList() {
		return this.recordTypeName === "Input_Record_List";
	}
	get isInputFlow() {
		return this.recordTypeName === "Input_Flow";
	}
	get isInputLookup() {
		return this.recordTypeName === "Input_Lookup";
	}
	get isCustomComponent() {
		return this.recordTypeName === "Custom_Component";
	}
	get customCmpName() {
		return this.detail?.Component_Name__c;
	}
}
