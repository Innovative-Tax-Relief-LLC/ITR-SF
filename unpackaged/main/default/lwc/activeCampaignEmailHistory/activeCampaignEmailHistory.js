import { LightningElement, wire, api, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHistories from '@salesforce/apex/ActiveCampaignEmailHistoryCtrl.getHistories';
import getEmailsHistories from '@salesforce/apex/ActiveCampaignEmailHistoryCtrl.getEmailsHistories';

import EMAIL_FIELD from "@salesforce/schema/Account.PersonEmail";
const fields = [EMAIL_FIELD];

export default class ActiveCampaignEmailHistory extends LightningElement {
    @api recordId;
    records = [];
    columns = [];
    totalRecords = 0;
    pageSize = 10;
    totalPages;
    pageNumber = 1;   
    recordsToDisplay = [];
    @track isLoading = false;

    @wire(getRecord, { recordId: "$recordId", fields })
    personAccount;
 
    connectedCallback() {
        this.isLoading = true;
        this.setColumns();

        // Busca os históricos de emails relacionados a Conta
        getHistories({accountId : this.recordId})
        .then(result => {
            if (result) {
                //Cria o link para o histórico
                result = JSON.parse(JSON.stringify(result));
                result.forEach(res => {
                    res.linkHistory = '/' + res.Id;
                });

                this.records = result;
                this.totalRecords =  result.length;                
                this.paginationHelper();
                this.isLoading = false;
            }
        }).catch(error => {
            console.log('Error Email histories ==>', error);
            this.showToast('Error', 'Error Email histories', 'error');
            this.isLoading = false;
        })
    }

    // Busca os históricos de Email
    searchEmail() {
        this.isLoading = true;

        // Verifica se o campo Email está preenchido
        if(!this.email) {
            this.showToast('Warning', 'Enter email address to search', 'warning');
            this.isLoading = false;
            return;
        }

        getEmailsHistories({email : this.email, accountId : this.recordId})
        .then(result => {
            if (result) {
            
                this.showToast(result.title, result.message, result.typeMessage);

                if(result.typeMessage == 'success') {
                    setTimeout(() => {
                        //Refresh na tela
                        window.location.reload();
                    }, "3000");
                }
                this.isLoading = false;
            }
        }).catch(error => {
            console.log('ERROR searchEmail ==>', error);
            this.showToast('Error', 'Error get email histories', 'error');
            this.isLoading = false;
        })
    }

    setColumns() {
        this.columns = [ 
            { 
                label: 'Name', 
                fieldName: 'linkHistory', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    target: '_blank' 
                },
            }, 
            { 
               label: 'Subject',
               fieldName: 'Subject__c',
            },
            { 
                label: 'Message',
                fieldName: 'Message__c',
            },
            {
                label: 'Date/Time Shipping',
                fieldName: 'Date_Time_Shipping__c',
                type: 'date',
                typeAttributes: {
                    year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit"
                },
            },
            {
                label: 'Opened',
                fieldName: 'Opened__c',
                type: 'boolean',
            },
            {
                label: 'Clicked',
                fieldName: 'Clicked__c',
                type: 'boolean',
            }
        ];
    }
    
    paginationHelper() {
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    get email() {
        return getFieldValue(this.personAccount.data, EMAIL_FIELD);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}