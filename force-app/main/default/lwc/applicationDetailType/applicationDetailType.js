import { api, LightningElement } from "lwc";
import customComponent from "c/testComponent";

export default class ApplicationDetailType extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api detail = {};

	@api isValid() {
		return this.refs.input?.completed;
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
	get isInputDate() {
		return this.recordTypeName === "Input_Date";
	}
	get isInputDateTime() {
		return this.recordTypeName === "Input_Date_Time";
	}
	get isCustomComponent() {
		return this.recordTypeName === "Custom_Component";
	}
}