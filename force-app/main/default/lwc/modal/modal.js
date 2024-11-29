/**
 * Created by EX300265 on 19/11/2024.
 */

import { api, LightningElement, track } from "lwc";

export default class Modal extends LightningElement {
  @track showModal = false;
  @api showIconButton = false;
  @api size = "large";
  @api header;
  sldsModalSize = "slds-modal_small";

  get showCloseButton(){
    return this?.showIconButton;
  }

  renderedCallback() {
    if (!this.showModal) return;

    switch (this.size) {
      case "small":
        this.sldsModalSize = "slds-modal_small";
        break;
      case "medium":
        this.sldsModalSize = "slds-modal_medium";
        break;
      case "x-small":
        this.sldsModalSize = "slds-modal_x-small";
        break;
      default:
        this.sldsModalSize = "slds-modal_large";
    }

    this.template.querySelector("section").classList.add(this.sldsModalSize);
  }

  //Função para abrir o modal do lado do component pai.
  //Basta chamar o componente e passar a funcao open()
  @api open(){
    this.showModal = true;
  }

  @api close() {
    this.showModal = false;
  }

}