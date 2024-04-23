import { api, track, LightningElement } from "lwc";
import fetchRecords from '@salesforce/apex/ApplicationHelper.fetchRecords';

const DELAY = 500;

export default class ApplicationInputLookup extends LightningElement {
    @api recordId;
	@api sectionId;
	@api language = "";
	@api languages = [];
	@api readOnly;
	@track _detail = {};

    recordsList = [];
    searchString = ''
    selectedRecordName;
    preventClosingOfSearchPanel = false;

    delaySearchTimeout
    delayBlurTimeout

    connectedCallback() {
        if (this.val) {
            this.fetchSobjectRecords(true);
        }
    }

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

    get objectApiName() {
        return this.detail?.Object_API_Name__c
    }
    get objectLabel() {
        return this.detail?.Object_Label__c
    }
    get primarySearchFieldAPIName() {
        return this.detail?.Primary_Search_Field_API_Name__c
    }
    get otherFieldAPIName() {
        return this.detail?.Other_Field_API_Name__c
    }
    get selectedIconName() {
        return this.detail?.SLDS_Icon_Name__c
    }

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.primarySearchFieldAPIName,
            otherFieldApiName: this.otherFieldAPIName,
            searchString: this.searchString,
            selectedRecordId: this.val,
            parentRecordId: '',
            parentFieldApiName: ''
            // parentRecordId: this.parentRecordId,
            // parentFieldApiName: this.parentFieldApiName
        };
    }

    get showRecentRecords() {
        return !!this.recordsList.length;
    }

    async fetchSobjectRecords(initLoad) {
        try {

            // if (this.readOnly) {
            //     return
            // }

            const result = await fetchRecords({
                inputWrapper: this.methodInput
            })

            if (initLoad && result) {
                this.selectedRecordName = result[0].mainField;
            } else if (result && !this.readOnly) {
                this.recordsList = JSON.parse(JSON.stringify(result));
            } else {
                this.recordsList = [];
            }
        } catch (error) {
            console.error(error);
        }
    }

    get isValueSelected() {
        return this.val;
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;

        window.clearTimeout(this.delaySearchTimeout);

        this.delaySearchTimeout = setTimeout(() => {
            this.fetchSobjectRecords(false);
        }, DELAY);
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSearchPanel = false;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSearchPanel = true;
    }

    handleCommit() {
        this.detail.Input_Text__c = '';
        this.selectedRecordName = '';
    }

    handleSelect(event) {
        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            id: event.currentTarget.dataset.id
        };
        this.detail.Input_Text__c = selectedRecord.id;
        this.selectedRecordName = selectedRecord.mainField;
        this.recordsList = [];

        this.dispatchEvent(
            new CustomEvent("detailchange", {
                composed: true,
                bubbles: true,
                detail: {
                    Id: this.id,
                    Input_Text__c: this.val
                }
            })
        );
    }

    handleInputBlur(event) {

        window.clearTimeout(this.delayBlurTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }

	// handleChange(event) {
	// 	const value = event.detail.value;

	// 	this.detail.Input_Text__c = value;

	// 	this.dispatchEvent(
	// 		new CustomEvent("detailchange", {
	// 			composed: true,
	// 			bubbles: true,
	// 			detail: {
	// 				Id: this.id,
	// 				Input_Text__c: value
	// 			}
	// 		})
	// 	);
	// }
}