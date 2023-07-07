import { track, api, LightningElement } from "lwc";

export default class ApplicationInputCheckbox extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = ''
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
		return this.language === 'English' ? 
		this.detail?.Field_Label__c :
		(this.detail?.Application_Detail_Languages__r
			?.find(item => item.Language__c === this.language))?.Translated_Text__c
	}
	get required() {
		return this.detail?.Required__c;
	}
	get val() {
		return this.detail?.Input_Checkbox__c;
	}

	handleChange(event) {
		const value = event.detail.checked;

		this.detail.Input_Checkbox__c = value;

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Checkbox__c: value
				}
			})
		);
	}
}