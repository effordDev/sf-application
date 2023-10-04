import { api, track, LightningElement } from "lwc";

export default class ApplicationInputText extends LightningElement {
	@api recordId;
	@api sectionId;
	@api language = "";
	@api languages = [];
	@api readOnly;
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
					?.Translated_Text__c || this.detail?.Field_Label__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
	get val() {
		return this.detail?.Input_Text__c || this.defaultValue;
	}
	get defaultValue() {
		return this.detail?.Default_Value__c || "";
	}
	get pattern() {
		return this.detail?.Pattern__c;
	}
	get patternMessage() {
		return this.detail?.Message_When_Pattern_Mismatch__c;
	}

	handleChange(event) {
		const value = event.detail.value;

		this.detail.Input_Text__c = value;

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Text__c: value
				}
			})
		);
	}
}
