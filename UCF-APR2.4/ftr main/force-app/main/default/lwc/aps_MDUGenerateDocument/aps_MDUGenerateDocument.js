/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 19-01-2024
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-01-2024   Monir Zaman   Initial Version
 **/
import { LightningElement, api } from "lwc";
import mduData from "@salesforce/apex/aps_GenerateDocument.mduData";

export default class Aps_MDUGenerateDocument extends LightningElement {
  rId;
  oppSpring_Folder;
  accSpring_Folder;

  @api set recordId(value) {
    this.rId = value;

    mduData({ rId: this.rId })
      .then((result) => {
        if (window.location.hostname === "ftr.lightning.force.com") {
          window.open(
            "https://na11.springcm.com/atlas/doclauncher/eos/MDU-Create-Agreements?aid=17662&eos[0].Id=" +
              this.rId +
              "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
              result[0].Spring_Folder_Name__c +
              "&eos[0].ScmPath=/Salesforce/Accounts/" +
              result[0].Account_Channel__c +
              "/" +
              result[0].Spring_Folder_Name__c,
            "_blank"
          );
        } else {
          window.open(
            "https://uatna11.springcm.com/atlas/doclauncher/eos/MDU-Create-Agreements?aid=7904&eos[0].Id=" +
              this.rId +
              "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
              result[0].Spring_Folder_Name__c +
              "&eos[0].ScmPath=/Salesforce/Accounts/" +
              result[0].Account_Channel__c +
              "/" +
              result[0].Spring_Folder_Name__c,
            "_blank"
          );
        }

        // this.dispatchEvent(new CloseActionScreenEvent());
      })
      .catch((error) => {
        console.log(error);
      });
  }
  get recordId() {
    return this.rId;
  }
}