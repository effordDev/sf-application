import { api, track, LightningElement } from "lwc";

export default class ApplicationInputPicklist extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@track _detail = {};

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	// connectedCallback()

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
		return this.detail?.Field_Label__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
	get val() {
		return this.detail?.Input_Text__c;
	}
	get picklistValues() {
		return this.detail?.Picklist_Values__c;
	}
	get options() {
		if (!this.picklistValues.split(";").length) {
			return [];
		}

		return this.picklistValues.split(";").map((value) => {
			
			value = value.trim()
			
			return {
				label: value,
				value
			};
		});
	}
	handleChange(event) {

		console.log(JSON.parse(JSON.stringify(this.options)))
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