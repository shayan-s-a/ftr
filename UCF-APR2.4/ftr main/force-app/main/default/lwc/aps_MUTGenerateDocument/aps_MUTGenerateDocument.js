/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 23-01-2024
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   20-11-2023   Monir Zaman   Initial Version
 **/
import { LightningElement, api } from "lwc";
import wholesaleData from "@salesforce/apex/aps_GenerateDocument.mtuData";

export default class Aps_MUTGenerateDocument extends LightningElement {
  rId;
  oppSpring_Folder;
  accSpring_Folder;

  @api set recordId(value) {
    this.rId = value;

    wholesaleData({ rId: this.rId })
      .then((result) => {
        if (result[0].Agreement_Type__c == "Marketing") {
          if (window.location.hostname === "ftr.lightning.force.com") {
            window.open(
              "https://na11.springcm.com/atlas/doclauncher/eos/MTU Marketing Agreement Config?aid=17662&eos[0].Id=" +
                this.rId +
                "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
                result[0].Spring_Contract_Folder_Name__c +
                "&eos[0].ScmPath=/Accounts/" +
                result[0].Account_Channel__c +
                "/" +
                result[0].Spring_Folder_Name__c,
              "_blank"
            );
          } else {
            window.open(
              "https://uatna11.springcm.com/atlas/doclauncher/eos/MTU Marketing Agreement Config?aid=7904&eos[0].Id=" +
                this.rId +
                "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
                result[0].Spring_Contract_Folder_Name__c +
                "&eos[0].ScmPath=/Salesforce/Accounts/" +
                result[0].Account_Channel__c +
                "/" +
                result[0].Spring_Folder_Name__c,
              "_blank"
            );
          }
        }

        if (result[0].Agreement_Type__c == "PAL") {
          if (window.location.hostname === "ftr.lightning.force.com") {
            window.open(
              "https://na11.springcm.com/atlas/doclauncher/eos/MTU PAL Agreement Config?aid=17662&eos[0].Id=" +
                this.rId +
                "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
                result[0].Spring_Contract_Folder_Name__c +
                "&eos[0].ScmPath=/Salesforce/Accounts/" +
                result[0].Account_Channel__c +
                "/" +
                result[0].Spring_Folder_Name__c,
              "_blank"
            );
          } else {
            window.open(
              "https://uatna11.springcm.com/atlas/doclauncher/eos/MTU PAL Agreement Config?aid=7904&eos[0].Id=" +
                this.rId +
                "&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=" +
                result[0].Spring_Contract_Folder_Name__c +
                "&eos[0].ScmPath=/Salesforce/Accounts/" +
                result[0].Account_Channel__c +
                "/" +
                result[0].Spring_Folder_Name__c,
              "_blank"
            );
          }
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }
  get recordId() {
    return this.rId;
  }
}