import { api, LightningElement } from 'lwc';
import getApplicationDetails from '@salesforce/apex/ApplicationHelper.getApplicationDetails'

export default class ApplicationAnswersSections extends LightningElement {
    @api recordId

    @api section = {}

    details = []
    connectedCallback() {
        this.fetchApplicationDetails()
    }

    get id() {
        return this.section?.Id
    }
    get displayName() {
        return this.section?.Display_Section_Label__c
    }

    async fetchApplicationDetails() {
        this.details = await getApplicationDetails({
            applicationSectionId: this.id
        })

        console.log(JSON.parse(JSON.stringify(this.details)))
    }
}
