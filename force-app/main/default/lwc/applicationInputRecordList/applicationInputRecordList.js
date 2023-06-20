import { api, track, LightningElement } from 'lwc';
import getFieldSet from '@salesforce/apex/ApplicationHelper.getFieldSet'
import getFieldSetData from '@salesforce/apex/ApplicationHelper.getFieldSetData'

export default class ApplicationInputRecordList extends LightningElement {
    @api recordId;
	@api sectionId;
	@api readOnly;
	@track _detail = {};

    fieldSet = []
    displayTableFieldSet = []
    data = []

    active = false
    isLoading = false

    async  connectedCallback() {
        console.log('record list');
        console.log(JSON.parse(JSON.stringify(this.detail)))

        try {
            
            this.isLoading = true
    
            this.fieldSet = await this.fetchFieldSet(
                this.childsObjectApi,
                this.childFieldSetApi
            )
            this.displayTableFieldSet = await this.fetchFieldSet(
                this.childsObjectApi,
                this.childDisplayTableFieldSetApi || this.childFieldSetApi
            )
            await this.fetchFieldSetData()
        } catch (error) {
            console.error(JSON.parse(JSON.stringify(error)))
        } finally {
            this.isLoading = false
        }
    }

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	@api get completed() {
		return this.required ? !!(this.data.length && this.required) : true
	}
    get editable() {
        return !this.readOnly
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
	get parentRelationshipApi() {
		return this.detail?.Child_To_Parent_Relationship_Api_Name__c
	}
	get childsObjectApi() {
		return this.detail?.Child_sObject_API_Name__c;
	}
	get childFieldSetApi() {
		return this.detail?.Child_sObject_Field_Set_API_Name__c;
	}
	get childDisplayTableFieldSetApi() {
		return this.detail?.Child_sObject_Table_Field_Set_API_Name__c;
	}
    get columns() {
        return this.displayTableFieldSet.map(field => {
            return {
                label: field?.label,
                fieldName: field?.name
            }
        })
    }
    get hideAddBtn() {
        return !this.active
    }

    async fetchFieldSet(sObjectName, fieldSetName) {
        return JSON.parse(await getFieldSet({
            sObjectName,
            fieldSetName
        })).map(field => {
            field.req = !field?.required === 'false'
            return field
        })
    }

    async fetchFieldSetData() {
        this.data = await getFieldSetData({
            parentId: this.recordId,
            sObjectName: this.childsObjectApi,
            fieldSetName: this.childFieldSetApi,
            parentRelationship: this.parentRelationshipApi
        })
        console.log('DATA')
        console.log(JSON.stringify(this.data))
        // console.log(JSON.parse(JSON.stringify(this.data)))
    }

	handleSubmit(event) {
        event.preventDefault()

        const fields = event.detail.fields
        fields.Demo_CC_Application__c = this.recordId
        this.template.querySelector('lightning-record-edit-form').submit(fields)
    } 

    handleSuccess(event){

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        )
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            })
        }

        const payload = event.detail;
        console.log(JSON.stringify(payload));

        this.fetchFieldSetData()
    }

    showInputs(event) {
        this.active = true
    }

    hideInputs(event) {

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        )

        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            })
        }

        this.active = false
    }
}