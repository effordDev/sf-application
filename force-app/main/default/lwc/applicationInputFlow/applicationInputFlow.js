import { api, track, LightningElement } from 'lwc';

export default class ApplicationInputFlow extends LightningElement {

    @api recordId;
	@api sectionId;
	@api readOnly;
    @api language = ''
	@track _detail = {}

    flowStatus = ''

    @api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	@api get completed() {
        return this.required ? this.flowIsCompleted : true
	}

    get inComplete() {
        return !this.completed
    }
    get flowIsCompleted() {
        return this.flowStatus === 'FINISHED'
    }

    get required() {
		return this.detail?.Required__c;
	}

	get id() {
		return this.detail?.Id
	}
    get flowApiName() {
        return this.detail?.Flow_API_Name__c
    }

    get flowInputVars() {
        return [
            {
                // Match with the input variable name declared in the flow.
                name: 'recordId',
                type: 'String',
                // Initial value to send to the flow input.
                value: this.recordId
            },
        ];
    }

	get label() {
		return this.language === 'English' ? 
		this.detail?.Field_Label__c :
		(this.detail?.Application_Detail_Languages__r
			.find(item => item.Language__c === this.language))?.Translated_Text__c
	}
	get required() {
		return this.detail?.Required__c;
	}

    handleStatusChange(event) {
        console.log(JSON.parse(JSON.stringify(event.detail)))

        //confirm flow has been completed once
        if (this.flowStatus !== 'FINISHED') {
            this.flowStatus = event.detail.status
        }
    }

}