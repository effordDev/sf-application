import LightningDatatable from "lightning/datatable";
import percent from './percent.html'

export default class ApplicationDatatable extends LightningDatatable {
    static customTypes = {
        percentfixed : {
            standardCellLayout: true,
            template : percent,
        } 
    }
}