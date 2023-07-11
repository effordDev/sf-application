import { api, LightningElement } from 'lwc';
import getApplication from '@salesforce/apex/ApplicationHelper.getApplication'

export default class ApplicationAnswers extends LightningElement {
    @api recordId

    application = {}

    connectedCallback() {
        this.fetchApplication()
    }

    get displayName() {
        return this.application?.Application_Display_Name__c
    }
    get name() {
        return this.application?.Name
    }
    get status() {
        return this.application?.Status__c
    }
    get createdDate() {
        return this.application?.CreatedDate
    }
    get sections() {
        return this.application?.Application_Sections__r || []
    }

    handleSectionHeaderClick(event) {
        const id = event.target.dataset.id

        const element = this.template.querySelector(`div[class="${id}"]`)


        element.scrollIntoView({ 
            behavior: "smooth", 
            block: "end", 
        });
    }

    async fetchApplication() {
        this.application = await getApplication({
            recordId: this.recordId
        })

        // console.log('application => ');
        // console.log(JSON.parse(JSON.stringify(this.application)))
    }
}