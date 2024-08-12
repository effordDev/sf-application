import { api, track, LightningElement } from 'lwc';
import applicationSaveAsDocumentOnRecord from '@salesforce/apex/UserSignature.applicationSaveAsDocumentOnRecord';
import applicationGetSignature from '@salesforce/apex/UserSignature.applicationGetSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApplicationSignature extends LightningElement {
    @api recordId
    @api title = 'Please Sign'
    @api width = '800'
    @api height = '300'
    @api type = 'png'
    @api readOnly = false

    @track cv = {}

    showPad = false

    @api get completed() {
        return !!this.cv?.Id
    }

    get isEmpty() { 
        return this.template.querySelector('c-signature-pad')?.isEmpty() 
    }
    get containerClass() {
        return `signature-container ${!!this.cv?.Id ? '' : 'error'}`
    }

    get editable() { 
        return !this.readOnly && !this.showPad 
    }
    get showCancel() { 
        return !!this.cv?.Id
    }

    get preview() {
        return `${this.cv?.VersionDataUrl}?thumb=THUMB240BY180`
    }
    get hasPreview() {
        return !!this.cv?.VersionDataUrl
    }

    renderedCallback(){ 
        // if (this.readOnly) return
        this.template.querySelector('c-signature-pad')?.resizeCanvas()
    }

    async connectedCallback() {
        await this.fetchSignature()

        if (!this.cv?.VersionDataUrl && this.editable) {
            this.showPad = true
        }
    }

    clear(){
        this.template.querySelector('c-signature-pad').clear();     
    }

    updateSignature() {
        this.showPad = true
    }
    handleCancel() {
        this.showPad = false
    }

    getDataUrl(){

        if(this.isEmpty){
            return console.log('isEmpty: ', this.isEmpty())
        }

        return this.template.querySelector('c-signature-pad').toDataURL()
    }

    async fetchSignature() {
        try {
            const result = await applicationGetSignature({
                recordId: this.recordId
            })
    
            this.cv = result
    
            // console.log('result')
            // console.log(JSON.parse(JSON.stringify(result)))
        } catch (error) {
            console.error(error)
        }
    }

    async save(){

        //convert to png image as dataURL
        const dataURL = this.getDataUrl()
        
        if(!dataURL){return undefined}

        if(location.hostname === "localhost"){
            const tab = window.open('', '_blank')
            tab.document.body.style.background = 'darkgrey'
            tab.document.body.innerHTML = `<img src="${dataURL}" width="auto" height="auto">`
            return
        }

        const recordId = this.recordId
        const extension = this.type
        const signature = dataURL.replace(/^data:image\/(png|jpg);base64,/, "")

        try {
            this.cv = await applicationSaveAsDocumentOnRecord({
                recordId,
                signature,
                extension,
            })

            this.showPad = false

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Salesforce File created with Signature',
                    variant: 'success',
                }),
            );
        } catch (error) {
            console.error(error)  
        }
    }
}