import { LightningElement, track } from 'lwc';
import SaveIcon from '@salesforce/resourceUrl/saveicon';
import GreenTick from '@salesforce/resourceUrl/greentick';
export default class SampleHRIS extends LightningElement {
    SaveBtnIcon = SaveIcon;
    GreeneBtnIcon = GreenTick;
    @track disabledStringBtn = 'disabled:true;';
}