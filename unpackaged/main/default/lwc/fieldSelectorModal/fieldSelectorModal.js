import { LightningElement, api } from 'lwc';
import getObjects from '@salesforce/apex/FieldSelectorModalController.getObjects';
import getFields from '@salesforce/apex/FieldSelectorModalController.getFields';

export default class FieldSelectorModal extends LightningElement {
    @api fromObject;
    @api returnObject;
    objectOptions = []; // List of available objects
    fieldOptions = []; // List of fields for the selected object
    selectedObject = ''; // Currently selected object
    selectedField = ''; // Currently selected field

    connectedCallback() {
        this.loadObjects();
    }

    loadObjects() {
        getObjects({ baseObject: this.returnObject, secondObject: this.fromObject })
            .then(data => {
                this.objectOptions = data.map(objectApiName => {
                    return {
                        label: objectApiName,
                        value: objectApiName 
                    };
                });
                this.selectedObject = this.returnObject;
                this.loadFields(this.returnObject);
            })
            .catch(error => {
                console.error('Error loading objects:', error);
            });
    }

    handleObjectChange(event) {
        this.selectedObject = event.target.value;
        this.loadFields(this.selectedObject);
    }

    loadFields(objectApiName) {
        getFields({ baseObject: objectApiName })
            .then(data => {
                this.fieldOptions = data.map(fieldApiName => {
                    return {
                        label: fieldApiName,
                        value: fieldApiName 
                    };
                });
            })
            .catch(error => {
                console.error('Error loading fields:', error);
            });
    }

    handleFieldChange(event) {
        this.selectedField = event.target.value;
    }

    handleSelect() {
        this.dispatchEvent(new CustomEvent('fieldselect', {
            detail: {
                fieldApiName: this.selectedField,
                objectApiName: this.selectedObject != this.returnObject ? this.selectedObject : null
            }
        }));
        this.handleClose();
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}