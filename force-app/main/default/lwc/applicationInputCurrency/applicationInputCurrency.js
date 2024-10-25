import { api, track, LightningElement } from "lwc";

export default class ApplicationInputCurrency extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api languages = [];
	@track _detail = {};

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	/*
	 * if required => make sure there is a value and required is == true
	 * if not required => return true
	 */
	@api get completed() {
		return [...this.template.querySelectorAll("lightning-input")].reduce(
			(validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			},
			true
		);

		// return this.required ? !!(this.val && this.required) : true
	}

	get id() {
		return this.detail?.Id;
	}
	get label() {
		return this.language === "English"
			? this.detail?.Field_Label__c
			: this.languages
					.filter((lang) => lang.Application_Detail__c === this.id)
					.find((item) => item.Language__c === this.language)
					?.Translated_Text__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
	get val() {
		return !isNaN(this.detail?.Input_Currency__c) ? this.detail?.Input_Currency__c : this.defaultValue;
	}
	get defaultValue() {
		return this.detail?.Default_Value__c || "";
	}
	get min() {
		return this.detail?.Minimum__c;
	}
	get max() {
		return this.detail?.Maximum__c;
	}
	get step() {
		return this.detail?.Step__c;
	}

	handleChange(event) {
		const value = event.detail.value;

		this.detail.Input_Currency__c = value;

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Currency__c: value
				}
			})
		);
	}
}
