import { api, LightningElement } from 'lwc';
import getRelatedApplicationRecord from '@salesforce/apex/ApplicationHelper.getRelatedApplicationRecord'

export default class RelatedApplication extends LightningElement {
    @api recordId
    @api apiFieldForApplicationId = ''
    applicationId = ''

    show = false

    async connectedCallback() {
        const result = await getRelatedApplicationRecord({
            recordId: this.recordId,
            field: this.apiFieldForApplicationId
        })
        this.applicationId = result[this.apiFieldForApplicationId]

        this.show = true
    }
}