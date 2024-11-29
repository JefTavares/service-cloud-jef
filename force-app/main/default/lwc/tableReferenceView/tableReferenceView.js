/**
 * Created by EX300265 on 18/11/2024.
 */

import { api, LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import utils from "c/utils";
import getRecords from "@salesforce/apex/ComponentViewController.getRecords";

export default class TableReferenceView extends LightningElement {
  @api recordId;
  @api objectApiName; //! Ta estranho, o objectApiName é setado getStateParameters e no botão

  //? Variáveis passadas nos metadados
  @api metadataName;
  @api componentTitle;
  @api hasCreateCaseButton = false;
  @api hasCreateOppButton = false;
  @api iconName;

  totalRows = 0;
  selectedRow = {};

  isLoading = false;

  //Definição da grid
  tableData = [];
  columns;

  //definição do modal
  labelHeader = "Selecione o Tipo de caso desejado";
  isLoadingModal = false;
  radioValue = [];
  radioLabel;
  //Variáveis do modal - recordTypes, tipos de records types ao criar um novo caso ou oportunidade
  options = [];

  get modal() {
    return this.template.querySelector("c-modal");
  }

  //TODO - Documentar funcionalidade disso
  get disableNext() {
    return utils.isEmptyObject(this.radioValue);
  }


  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    //Pega a página atual e atribui os valores dos campos recordId
    if (currentPageReference) {
      this.recordId = utils.isEmptyString(currentPageReference.state.recordId) ? currentPageReference.attributes.recordId : currentPageReference.state.recordId;
      this.objectApiName = currentPageReference.attributes.objectApiName;
      console.log("currentPageReference >>>", currentPageReference);
    }
  }

  connectedCallback() {
    //super.connectedCallback();
    this.isLoading = true;
    console.log("<<< component init >>>");
    console.log("metadataName >>>", this.metadataName);
    console.log("this.recordId >>>", this.recordId);
    console.log("this.objectApiName >>>", this.objectApiName);
    const dataWrapper = {
      metadataName: this.metadataName,
      objectApiName: this.objectApiName,
      recordId: this.recordId
    };

    getRecords({ dataString: JSON.stringify(dataWrapper) }).then((result) => {
      console.log("result obj >>>", result);
      this.columns = JSON.parse(result.Columns);
      console.log("this.columns >>>");
      console.log(JSON.stringify(this.columns));

      //Adiciona um botão extra para criação de casos
      if (this.hasCreateCaseButton) this.columns = [...this.columns, {
        label: "Criar Atendimento", type: "button-icon", fixedWidth: 150, typeAttributes: {
          iconName: "utility:new", name: "createCase", title: "Criar Atendimento",
          variant: "brand", alternativeText: "Criar Atendimento"
        }
      }];
      //Adiciona um botão extra para criação de oportunidades
      if (this.hasCreateOppButton) this.columns = [...this.columns, {
        label: "Criar Oportunidade", type: "button-icon", fixedWidth: 150, typeAttributes: {
          iconName: "utility:new", name: "createOpp", title: "Criar Oportunidade",
          variant: "brand", alternativeText: "Criar Oportunidade"
        }
      }];

      delete result.Columns;
      this.setRecordTypes(JSON.parse(result.RecordTypes));
      console.log("Records Type disponíveis:" + this.options);

      delete result.RecordTypes;
      console.log("result object >>>", JSON.parse(Object.values(result)));

      const responseAPI = JSON.parse(Object.values(result));
      console.log("response >>>" + responseAPI);
      console.log(JSON.stringify(responseAPI));

      console.log("this.columns >>>", this.columns);
      let auxTable = [];
      let i = 0;

      //TODO Mudar para um swtich case e métodos separados
      if (this.metadataName === "Massificados") {
        //TODO lista dos massificados
      } else if (this.metadataName === "Afinidades") {
        auxTable = responseAPI.return_x.apolice.map(item => {
          console.log("typeof >>>", typeof item);
          console.log("Afinidades item >>>", item);
          item.dados.tipoCML = "Habitacional";
          item.dados.status = this.checkData(item.dados.vigFinal, item.dados.status);
          let aux = this.setupObject(item);
          return {
            id: i++, ...item, ...aux
          };
        });
      }
      //todo criar dos outros métodos e grids


      this.tableData = JSON.parse(JSON.stringify(auxTable));
      this.totalRows = this.tableData.length;
      console.log("tableData >>>", this.tableData);
      this.isLoading = false;
    }).catch(err => {
      console.log("err >>>");
      console.log(JSON.stringify(err));
      utils.showToast(this, "warning", this.componentTitle, "Não há informações recuperadas da API.", "dismissable");
      this.isLoading = false;
    });


  }


  //todo handleRowAction
  handleRowAction(event) {
    this.isLoadingModal = true;
    console.log("handleRowAction:", event);
    const { row } = event.detail;
    console.log("row log");
    console.log(row);

    this.selectedRow = event.detail.row;
    const actionName = event.detail.action.name;
    console.log("actionName >>>", actionName);
    console.log("row >>>", row);
    console.log("this.selectedRow >>>", this.selectedRow);
    console.log("=========END LOG=========");

    if (actionName === "createCase") {
      this.objectApiName = "Case";
      this.modal.open();
    }
    if (actionName === "createOpp") {
      this.objectApiName = "Opportunity";
      //todo mudar a criação da variavel row para ka
      this.createRecord(row, "");
    }

    this.isLoadingModal = false;


  }

  get showTable() {
    return !utils.isEmptyArray(this.tableData);
  }

  setupObject(data) {
    console.log("data >>>", data);
    let aux = [];
    for (let key in data) {
      console.log("key >>>", key);
      console.log("data >>>", data);
      console.log("data[key] >>>", data[key]);
      console.log("typeof data[key] >>>", typeof data[key]);
      data[key] = data[key] == null ? "" : data[key];
      console.log("typeof data[key] >>>", typeof data[key]);
      if (typeof data[key] === "object") aux = Object.assign(aux, Object.fromEntries(Object.entries(data[key])));
      console.log("aux >>> ", aux);
      console.log("aux >>> ", JSON.stringify(aux));
    }
    console.log("aux >>>", JSON.parse(JSON.stringify(aux)));
    return aux;
  }

  setRecordTypes(recordTypes) {
    this.options = recordTypes.map(item => ({
      label: item?.Name,
      value: item?.Id,
      description: item?.Description
    }));
    console.log("recordTypes: >>>", recordTypes);
  }

  checkData(date, status) {
    if (Date.now() > Date.parse(date) && status === "ACT")
      return "FIM";
    return status;
  }

  //Funções dos modais
  handleCloseModal() {
    this.modal.close();
  }

  handleClick() {
    this.isLoadingModal = true;
    this.createRecord(this.selectedRow, this.radioValue, this.radioLabel);
  }


}