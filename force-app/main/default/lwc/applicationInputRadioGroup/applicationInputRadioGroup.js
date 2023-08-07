import { api, track, LightningElement } from "lwc";

export default class ApplicationInputRadioGroup extends LightningElement {
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

	// connectedCallback() {
	// 	console.log(JSON.parse(JSON.stringify(this.detail)))
	// }

	/*
	 * if required => make sure there is a value and required is == true
	 * if not required => return true
	 */
	@api get completed() {
		
		const completed = ([...this.template.querySelectorAll("lightning-radio-group")].reduce(
			(validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true
			) 
			&& (this.hasChildRecords && !!this.childrenNodes?.length 
				? this.childrenValidated 
				: true 
			))
			return completed
	}

	get childrenValidated() {
		console.log('validating... children...');
		
		const appDetailsTypes = this.template.querySelectorAll(
			"c-application-detail-type.customInput"
		);

		let allValidArray = [];

		appDetailsTypes.forEach((curr) => {
			// console.log(curr)
			// console.log(curr.isValid())
			allValidArray.push(curr.isValid());
		});

		console.log(allValidArray)

		const isAllValid = allValidArray.every((item) => !!item);

		return isAllValid
	}
	get childrenNodes() {
		return [...this.template.querySelectorAll("c-application-detail-type.customInput")]
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
		return this.detail?.Input_Text__c;
	}
	get dependentParentAnswer() {
		return this.detail?.Parent_Dependent_Answer__c || ''
	}
	get picklistValues() {
		return this.detail?.Radio_Group_Values__c || ''
	}
	// get showChildRecords() {
	// 	return (this.hasChildRecords && (this.dependentParentAnswer.includes(this.val)))
	// }
	get showChildRecords() {
		return (this.hasChildRecords && this.dependentChildRecords.length)
	}
	get hasChildRecords() {
		return !!this.childRecords.length
	}
	get childRecords() {
		return this.detail?.Application_Details__r || []
	}
	get dependentChildRecords() {
		return this.childRecords.filter(child => child?.Parent_Dependent_Answer__c === this.detail.Input_Text__c) || []
	}
	get options() {
		if (!this.picklistValues.length) {
			return [
				{label:'N/A', value:'N/A'}
			]
		}
		if (!this.picklistValues.split(";").length) {
			return [
				{label:'N/A', value:'N/A'}
			]
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

		// console.log(JSON.parse(JSON.stringify(this.options)))
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