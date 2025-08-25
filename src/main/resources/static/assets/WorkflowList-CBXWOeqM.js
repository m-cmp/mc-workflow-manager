import{_ as N}from"./TableHeader.vue_vue_type_script_setup_true_lang-BR3V6Gtc.js";import{_ as D}from"./request-CzLG2g7g.js";import{d as L,P as F,r as P,a as R,b as S,g as B}from"./ParamForm-B31Z6Vgs.js";import{d as g,u as y,a as m,b as t,t as W,h as w,c as I,r as f,w as $,k as E,j as h,l as V,F as A,f as G,o as T,m as C,i as p,n as O}from"./index-DirzPYr2.js";const U={class:"modal modal-blur fade",id:"deleteWorkflow",tabindex:"-1","aria-hidden":"true"},j={class:"modal-dialog modal-lg modal-dialog-centered",role:"document"},z={class:"modal-content"},M={class:"modal-body py-4"},q={class:"modal-footer"},H=g({__name:"DeleteWorkflow",props:{workflowName:{},workflowIdx:{}},emits:["get-workflow-list"],setup(v,{emit:b}){const d=y(),r=v,i=b,o=async()=>{const{data:l}=await L(r.workflowIdx);l?d.success("삭제되었습니다."):d.error("삭제하지 못했습니다."),i("get-workflow-list")};return(l,a)=>(w(),m("div",U,[t("div",j,[t("div",z,[a[2]||(a[2]=t("div",{class:"modal-status bg-danger"},null,-1)),a[3]||(a[3]=t("div",{class:"modal-header"},[t("h3",{class:"modal-title"},"Delete Workflow"),t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"})],-1)),t("div",M,[t("h4",null,"Are you sure you want to delete "+W(r.workflowName)+"?",1)]),t("div",q,[a[1]||(a[1]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:a[0]||(a[0]=e=>o())}," Delete ")])])])]))}}),J={class:"modal modal-blur fade",id:"runWorkflow",tabindex:"-1","aria-hidden":"true"},K={class:"modal-dialog modal-lg modal-dialog-centered",role:"document"},Q={class:"modal-content"},X={class:"modal-body py-4"},Y={class:"modal-footer"},Z=g({__name:"RunWorkflow",props:{workflowIdx:{}},emits:["get-workflow-list"],setup(v,{emit:b}){const d=y(),r=v,i=b,o=I(()=>r.workflowIdx),l=f({});$(()=>o.value,async()=>{const{data:e}=await R(o.value,"N");l.value=e});const a=async()=>{d.success("워크플로우가 실행 되었습니다."),i("get-workflow-list"),await P(l.value).then(({data:e})=>{e?d.success("워크플로우가 정상적으로 완료 되었습니다."):d.error("워크플로우가 정상적으로 완료 되지 못했습니다."),i("get-workflow-list")})};return(e,n)=>(w(),m("div",J,[t("div",K,[t("div",Q,[n[2]||(n[2]=t("div",{class:"modal-status bg-info"},null,-1)),n[3]||(n[3]=t("div",{class:"modal-header"},[t("h3",{class:"modal-title"},"Run Workflow"),t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"})],-1)),t("div",X,[l.value.workflowParams?(w(),E(F,{key:0,popup:!0,"workflow-param-data":l.value.workflowParams,"event-listener-yn":"N"},null,8,["workflow-param-data"])):h("",!0)]),t("div",Y,[n[1]||(n[1]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:n[0]||(n[0]=k=>a())}," Run ")])])])]))}}),tt={class:"modal",id:"workflowLog",tabindex:"-1"},ot={class:"modal-dialog modal-xl",role:"document"},st={class:"modal-content"},at={class:"modal-body text-left py-4"},et={class:"mb-5"},lt={key:0,class:"spinner-border",role:"status"},nt={key:0},dt={class:"card mb-3"},rt=["onClick"],it={class:"card-title"},ct={key:0,class:"card-body"},ut=["value"],wt=g({__name:"WorkflowLog",props:{workflowIdx:{}},emits:["get-oss-list"],setup(v,{emit:b}){y();const d=v,r=f(!1),i=I(()=>d.workflowIdx);$(i,async()=>{r.value=!1,await l()});const o=f([]),l=async()=>{o.value=[],await S(i.value).then(({data:k})=>{o.value=k,r.value=!0})},a=()=>{o.value=[],e.value=1},e=f(1),n=k=>{e.value===k?e.value=0:e.value=k};return(k,c)=>(w(),m("div",tt,[t("div",ot,[t("div",st,[c[3]||(c[3]=t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1)),t("div",at,[t("h3",et,[c[1]||(c[1]=V(" Workflow Log ")),r.value?h("",!0):(w(),m("div",lt,c[0]||(c[0]=[t("span",{class:"visually-hidden"},"Loading...",-1)])))]),t("div",null,[o.value.length<=0?(w(),m("div",nt,c[2]||(c[2]=[t("p",{class:"text-secondary"},"No Data",-1)]))):(w(!0),m(A,{key:1},G(o.value,s=>(w(),m("div",{key:s.buildIdx},[t("div",dt,[t("div",{class:"card-header",onClick:u=>n(s.buildIdx),style:{cursor:"pointer"}},[t("h3",it,W(s.buildIdx),1)],8,rt),e.value===s.buildIdx?(w(),m("div",ct,[t("textarea",{value:s.buildLog,disabled:"",style:{width:"100%"},rows:"20"},null,8,ut)])):h("",!0)])]))),128))])]),t("div",{class:"modal-footer"},[t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal",onClick:a}," Cancel ")])])])]))}}),mt={class:"card card-flush w-100"},ft={class:"card-body"},_t=g({__name:"WorkflowList",setup(v){const b=f(!0);y();const d=f([]),r=f([]);T(async()=>{a(),await i()});const i=async()=>{try{b.value=!0,await B("N").then(({data:s})=>{b.value=!1,d.value=s})}catch(s){console.log(s)}},o=f(0),l=f(""),a=()=>{r.value=[{title:"Workflow Name",field:"workflowInfo.workflowName",width:"30%"},{title:"Workflow Purpose",field:"workflowInfo.workflowPurpose",width:"10%"},{title:"Status",field:"workflowInfo.status",width:"10%",formatter:k},{title:"Params Count",formatter:n,width:"10%"},{title:"Created Date",field:"regDate",width:"20%"},{title:"Action",width:"20%",formatter:c,cellClick:async(s,u)=>{const _=s.target,x=_==null?void 0:_.getAttribute("id");o.value=u.getRow().getData().workflowInfo.workflowIdx,x==="detail-btn"?C.push("/web/workflow/detail/"+o.value):x==="delete-btn"&&(l.value=u.getRow().getData().workflowInfo.workflowName)}}]},e=()=>{C.push("/web/workflow/new")},n=s=>`<span>${s._cell.row.data.workflowParams.length}</span>`,k=s=>{const u=s.getValue();return`
  <div>
    <span class="
      status
      ${u==="SUCCESS"?"status-green":u==="FAILED"?"status-red":u==="IN_PROGRESS"?"status-blue":""}" 
    >
      <span class="status-dot"></span>
      ${u}
    </span>
  </div>
  `},c=()=>`
    <div>
      <button
        class='btn btn-primary d-none d-sm-inline-block'
        id='detail-btn'
        style='margin-right: 5px'>
          Detail
      </button>
      <button class='btn btn-danger d-none d-sm-inline-block'
        id='delete-btn'
        data-bs-toggle='modal' 
        data-bs-target='#deleteWorkflow'
        style='margin-right: 5px'>
        DELETE
      </button>
      <button class='btn btn-info d-none d-sm-inline-block'
        id='run-btn'
        data-bs-toggle='modal' 
        data-bs-target='#runWorkflow'>
        RUN
      </button>
      <button class='btn btn-primary d-none d-sm-inline-block'
        id='log-btn'
        data-bs-toggle='modal' 
        data-bs-target='#workflowLog'>
        LOG
      </button>
    </div>`;return(s,u)=>{const _=O("b-overlay");return w(),m("div",null,[p(N,{"header-title":"Workflow","new-btn-title":"New Workflow","popup-flag":!1,"popup-target":"",onClickNewBtn:e}),t("div",mt,[t("div",ft,[p(D,{columns:r.value,"table-data":d.value},null,8,["columns","table-data"])])]),p(H,{"workflow-name":l.value,"workflow-idx":o.value,onGetWorkflowList:i},null,8,["workflow-name","workflow-idx"]),p(Z,{"workflow-idx":o.value,onGetWorkflowList:i},null,8,["workflow-idx"]),p(wt,{"workflow-idx":o.value},null,8,["workflow-idx"]),p(_,{show:b.value,id:"overlay-background",variant:"transparent",opacity:"1",blur:"1rem",rounded:"lg",style:{"z-index":"1000"}},null,8,["show"])])}}});export{_t as default};
