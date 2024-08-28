import{_ as y,a as W}from"./Tabulator.vue_vue_type_style_index_0_lang-DuAobM9_.js";import{d as x,P as C,r as $,g as N,a as I}from"./ParamForm-CW_WJD9-.js";import{d as _,u as p,a as h,b as o,t as D,h as k,c as P,r as c,w as B,k as F,j as L,o as R,l as v,i as u}from"./index-DwHi2I-I.js";import"./request-DA8z9s8Q.js";const V={class:"modal",id:"deleteWorkflow",tabindex:"-1"},A={class:"modal-dialog modal-lg",role:"document"},G={class:"modal-content"},T=o("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1),j=o("div",{class:"modal-status bg-danger"},null,-1),E={class:"modal-body text-left py-4"},M=o("h3",{class:"mb-5"}," Workflow 삭제 ",-1),S={class:"modal-footer"},q=o("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1),z=_({__name:"DeleteWorkflow",props:{workflowName:{},workflowIdx:{}},emits:["get-workflow-list"],setup(w,{emit:d}){const a=p(),e=w,l=d,n=async()=>{const{data:t}=await x(e.workflowIdx);t?a.success("삭제되었습니다."):a.error("삭제하지 못했습니다."),l("get-workflow-list")};return(t,i)=>(k(),h("div",V,[o("div",A,[o("div",G,[T,j,o("div",E,[M,o("h4",null,D(e.workflowName)+"을(를) 정말 삭제하시겠습니까?",1)]),o("div",S,[q,o("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:i[0]||(i[0]=r=>n())}," 삭제 ")])])])]))}}),H={class:"modal",id:"runWorkflow",tabindex:"-1"},J={class:"modal-dialog modal-lg",role:"document"},K={class:"modal-content"},O=o("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1),Q=o("div",{class:"modal-status bg-danger"},null,-1),U={class:"modal-body text-left py-4"},X=o("h3",{class:"mb-5"}," Workflow 실행 ",-1),Y={class:"modal-footer"},Z=o("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1),oo=_({__name:"RunWorkflow",props:{workflowIdx:{}},emits:["get-workflow-list"],setup(w,{emit:d}){const a=p(),e=w,l=d,n=P(()=>e.workflowIdx),t=c({});B(()=>n.value,async()=>{const{data:r}=await N(n.value,"N");t.value=r});const i=async()=>{const{data:r}=await $(t.value);r?a.success("실행되었습니다."):a.error("실행하지 못했습니다."),l("get-workflow-list")};return(r,m)=>(k(),h("div",H,[o("div",J,[o("div",K,[O,Q,o("div",U,[X,t.value.workflowParams?(k(),F(C,{key:0,popup:!0,"workflow-param-data":t.value.workflowParams},null,8,["workflow-param-data"])):L("",!0)]),o("div",Y,[Z,o("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:m[0]||(m[0]=s=>i())}," 실행 ")])])])]))}}),to={class:"card card-flush w-100"},no=_({__name:"WorkflowList",setup(w){p();const d=c([]),a=c([]);R(async()=>{t(),await e()});const e=async()=>{try{const{data:s}=await I("N");d.value=s}catch(s){console.log(s)}},l=c(0),n=c(""),t=()=>{a.value=[{title:"Workflow Name",field:"workflowInfo.workflowName",width:500},{title:"Workflow Purpose",field:"workflowInfo.workflowPurpose",width:200},{title:"Params Count",formatter:r,width:400},{title:"Created Date",field:"regDate",width:400},{title:"Action",width:400,formatter:m,cellClick:async(s,f)=>{const b=s.target,g=b==null?void 0:b.getAttribute("id");l.value=f.getRow().getData().workflowInfo.workflowIdx,g==="edit-btn"?v.push("/web/workflow/edit/"+l.value):g==="delete-btn"&&(n.value=f.getRow().getData().workflowInfo.workflowName)}}]},i=()=>{v.push("/web/workflow/new")},r=s=>`<span>${s._cell.row.data.workflowParams.length}</span>`,m=()=>`
    <div>
      <button
        class='btn btn-primary d-none d-sm-inline-block'
        id='edit-btn'
        style='margin-right: 5px'>
          수정
      </button>
      <button class='btn btn-danger d-none d-sm-inline-block'
        id='delete-btn'
        data-bs-toggle='modal' 
        data-bs-target='#deleteWorkflow'
        style='margin-right: 5px'>
        삭제
      </button>
      <button class='btn btn-info d-none d-sm-inline-block'
        id='run-btn'
        data-bs-toggle='modal' 
        data-bs-target='#runWorkflow'>
        실행
      </button>
    </div>`;return(s,f)=>(k(),h("div",to,[u(W,{"header-title":"Workflow","new-btn-title":"New Workflow",popupFlag:!1,popupTarget:"",onClickNewBtn:i}),u(y,{columns:a.value,"table-data":d.value},null,8,["columns","table-data"]),u(z,{"workflow-name":n.value,"workflow-idx":l.value,onGetWorkflowList:e},null,8,["workflow-name","workflow-idx"]),u(oo,{"workflow-idx":l.value,onGetWorkflowList:e},null,8,["workflow-idx"])]))}});export{no as default};
