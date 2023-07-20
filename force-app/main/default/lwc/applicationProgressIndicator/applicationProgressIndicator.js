import { api, LightningElement } from 'lwc';

export default class ApplicationProgressIndicator extends LightningElement {
    @api items = []
    @api activeSectionId = ''
}