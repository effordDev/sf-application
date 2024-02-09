import { api, LightningElement } from 'lwc';

import Signature from './signature_pad'

export default class SignaturePad extends LightningElement {

    /**
     * (String) Set width of canvas to sign on
     */
    @api width = '1000'

    /**
     * (String) Set height of canvas to sign on
     */
    @api height = '400'

    /**
     * (String) Color used to clear the background. Can be any color format accepted by context.fillStyle. Defaults to white "rgb(255,255,255)". Use a non-transparent color e.g. "rgb(255,255,255)" (opaque white) if you'd like to save signatures as JPEG images.
     */
    @api backgroundColor = 'rgb(255,255,255)';

    /**
     * (String) Color used to draw the lines. Can be any color format accepted by context.fillStyle. Defaults to "black".
     */
    @api penColor = 'rgb(0,0,0)';

    /**
     *  Draws signature image from data URL.
     *  NOTE: This method does not populate internal data structure that represents drawn signature. Thus, after using #fromDataURL, #toData won't work properly.
     *  this.signaturePad.fromDataURL("data:image/png;base64,iVBORw0K...");
     */
    @api existingSignature = undefined

    /**
     * 
     * @param {String} type -  Defaults to PNG; Options: blank || 'image/jpeg' || 'image/svg+xml'
     */
    @api
    toDataURL(type = ''){

        return this.signaturePad.toDataURL(type)
    }

    /**
     * Returns signature image as an array of point groups
     */
    @api
    toData(){

        return this.signaturePad.toData()
    }

    /**
     * Returns signature image as an array of point groups
     */
    @api
    isEmpty(){

        return this.signaturePad.isEmpty()
    }

    /**
     * Clears the canvas
     */
    @api
    clear(){
        return this.signaturePad.clear(); 
    }
    
    /**
     * Unbinds all event handlers
     */
    @api
    off(){
        return this.signaturePad.off()
    }

    /**
     * Rebinds all event handlers
     * - attach == on 
     */
    @api
    attach(){
        return this.signaturePad.on()
    }

    renderedCallback() {

        window.addEventListener("resize", this.resizeCanvas.bind(this))

        if(this.width){ this.template.querySelector("canvas").style.width = this.width }
        if(this.height){ this.template.querySelector("canvas").style.height = this.height }
        
        this.signaturePad = new Signature( this.template.querySelector("canvas"), {
            penColor: this.penColor,
            backgroundColor: this.backgroundColor,
        })

        this.resizeCanvas()

        if(this.existingSignature){

            // Draws signature image from data URL.
            // NOTE: This method does not populate internal data structure that represents drawn signature. Thus, after using #fromDataURL, #toData won't work properly.
            this.signaturePad.fromDataURL(this.existingSignature)
        }
    }

    get canvas(){ return this.template.querySelector("canvas") }

    @api
    resizeCanvas() {
        const canvas = this.template.querySelector("canvas")
        const max = {w: '1000', h: '250'}
        const maxed = (x,m) => x > max[m]
        const calc = (o,r,m) => maxed(o * r, m) ? max[m] : o * r
        const ratio =  Math.max(window.devicePixelRatio || 1, 1)
        canvas.width = calc(canvas.offsetWidth, ratio, 'w')
        canvas.height = calc(canvas.offsetHeight, ratio, 'h')
        canvas.getContext("2d").scale(ratio, ratio);
        this.clear(); // otherwise isEmpty() might return incorrect value
    }
}