import { LightningElement, api, track } from 'lwc';
import sendClientApi from "@salesforce/apex/ObjectToPitBullTaxApiService.sendClientApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SendToPitBullTaxApiButtons extends LightningElement {
    @api recordId;
    @track isLoading = false;

    handleClickPersonal() {
        if (confirm('Are you sure you want create this client?')) {
            this.callSendClientApi(false, false);
        }
    }

    handleClickBusiness() {
        if (confirm('Are you sure you want create this client + business?')) {
            this.callSendClientApi(false, true);
        }
    }

    handleClickUpdatePersonal() {
        if (confirm('Are you sure you want update this client?')) {
            this.callSendClientApi(true, false);
        }
    }

    callSendClientApi(isUpdate, sendBusinesses) {
        this.isLoading = true;
        sendClientApi({ ids: [this.recordId], isUpdate: isUpdate , sendBusinesses: sendBusinesses})
            .then(() => {
                this.showToast('Success', 'Client data sent successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            })
        );
    }
}