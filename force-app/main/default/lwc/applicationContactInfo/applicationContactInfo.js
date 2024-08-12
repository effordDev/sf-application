import { api, track, LightningElement } from "lwc";
// import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi"

export default class ApplicationContactInfo extends LightningElement {
	@api recordId;
	@api detail = {};
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api contact = {};

	@track contactInfo;

	@api get completed() {
		return [
			...this.template.querySelectorAll("lightning-input, lightning-combobox")
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
	}

	get id() {
		return this.contact?.Id;
	}
	get title() {
		return this.contact?.Title;
	}
	get firstName() {
		return this.contact?.FirstName;
	}
	get lastName() {
		return this.contact?.LastName;
	}
	get email() {
		return this.contact?.Email;
	}
	get dob() {
		return this.contact?.Birthdate;
	}
	get mobilePhone() {
		return this.contact?.MobilePhone;
	}

	get customJSONSettings() {
		if (isJSON(this.detail.Custom_Component_JSON__c)) {
			return JSON.parse(this.detail.Custom_Component_JSON__c);
		}
		return {};
	}

	get showFirstName() {
		return this.customJSONSettings?.fieldsToShow?.includes("FirstName");
	}
	get showLastName() {
		return this.customJSONSettings?.fieldsToShow?.includes("LastName");
	}
	get showEmail() {
		return this.customJSONSettings?.fieldsToShow?.includes("Email");
	}
	get showBirthDate() {
		return this.customJSONSettings?.fieldsToShow?.includes("BirthDate");
	}
	get showMobilePhone() {
		return this.customJSONSettings?.fieldsToShow?.includes("MobilePhone");
	}
	get showTitle() {
		return this.customJSONSettings?.fieldsToShow?.includes("Title");
	}

	handleChange(event) {
		const value = event.detail.value;
		const field = event.target.name;

		// console.log({
		// 	field,
		// 	value
		// });

		this.dispatchEvent(
			new CustomEvent("sobchange", {
				composed: true,
				bubbles: true,
				detail: {
					id: this.id,
					field,
					value
				}
			})
		);
	}
}

const isJSON = (string) => {
	try {
		JSON.parse(string);
		return true;
	} catch (error) {
		return false;
	}
};