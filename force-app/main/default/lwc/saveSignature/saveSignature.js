import { api, LightningElement } from 'lwc';
import saveAsDocumentOnRecord from '@salesforce/apex/UserSignature.saveAsDocumentOnRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SaveSignature extends LightningElement {

    @api recordId
    @api title = 'Please Sign'
    @api width = '800'
    @api height = '300'
    @api type = 'png'

    @api get completed() {
        return true
    }

    get isEmpty() { return this.template.querySelector('c-signature-pad').isEmpty() }

    renderedCallback(){ 
        this.template.querySelector('c-signature-pad').resizeCanvas()
    }

    clear(){
        this.template.querySelector('c-signature-pad').clear();     
    }

    getDataUrl(){

        if(this.isEmpty){
            return console.log('isEmpty: ', this.isEmpty())
        }

        return this.template.querySelector('c-signature-pad').toDataURL()
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
            const result = await saveAsDocumentOnRecord({
                recordId,
                signature,
                extension,
            })

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Salesforce File created with Signature',
                    variant: 'success',
                }),
            );
            return result
        } catch (error) {
            console.error(error)  
        }
        
        //call Apex method imperatively and use promise for handling sucess & failure
        /* saveSign({strSignElement: convertedDataURI,recId : this.recordId})
            .then(result => {
                //this.ContentDocumentLink = result;
                //console.log('ContentDocumentId=' + this.ContentDocumentLink.ContentDocumentId);
                //show success message
                this.handleClearClick()

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Salesforce File created with Signature',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                //show error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Salesforce File record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            }); */
    }
}