import{_ as N}from"./TableHeader.vue_vue_type_script_setup_true_lang-C_qJD6Ab.js";import{_ as D}from"./request-yXkfYzDC.js";import{d as L,P as F,a as P,r as R,b as S,g as B}from"./ParamForm-B65R7MQu.js";import{d as g,u as y,a as w,b as m,e as t,t as W,c as I,r as f,w as $,k as E,j as x,l as V,F as A,g as G,o as T,m as C,n as O,i as p}from"./index-C4tmnPpu.js";const U={class:"modal",id:"deleteWorkflow",tabindex:"-1"},j={class:"modal-dialog modal-lg",role:"document"},z={class:"modal-content"},M={class:"modal-body text-left py-4"},q={class:"modal-footer"},H=g({__name:"DeleteWorkflow",props:{workflowName:{},workflowIdx:{}},emits:["get-workflow-list"],setup(v,{emit:b}){const r=y(),d=v,i=b,o=async()=>{const{data:n}=await L(d.workflowIdx);n?r.success("삭제되었습니다."):r.error("삭제하지 못했습니다."),i("get-workflow-list")};return(n,s)=>(w(),m("div",U,[t("div",j,[t("div",z,[s[3]||(s[3]=t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1)),s[4]||(s[4]=t("div",{class:"modal-status bg-danger"},null,-1)),t("div",M,[s[1]||(s[1]=t("h3",{class:"mb-5"}," Delete Workflow ",-1)),t("h4",null,"Are you sure you want to delete "+W(d.workflowName)+"?",1)]),t("div",q,[s[2]||(s[2]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:s[0]||(s[0]=l=>o())}," Delete ")])])])]))}}),J={class:"modal",id:"runWorkflow",tabindex:"-1"},K={class:"modal-dialog modal-lg",role:"document"},Q={class:"modal-content"},X={class:"modal-body text-left py-4"},Y={class:"modal-footer"},Z=g({__name:"RunWorkflow",props:{workflowIdx:{}},emits:["get-workflow-list"],setup(v,{emit:b}){const r=y(),d=v,i=b,o=I(()=>d.workflowIdx),n=f({});$(()=>o.value,async()=>{const{data:l}=await P(o.value,"N");n.value=l});const s=async()=>{r.success("워크플로우가 실행 되었습니다."),await R(n.value).then(({data:l})=>{l?r.success("워크플로우가 정상적으로 완료 되었습니다."):r.error("워크플로우가 정상적으로 완료 되지 못했습니다."),i("get-workflow-list")})};return(l,a)=>(w(),m("div",J,[t("div",K,[t("div",Q,[a[3]||(a[3]=t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1)),a[4]||(a[4]=t("div",{class:"modal-status bg-danger"},null,-1)),t("div",X,[a[1]||(a[1]=t("h3",{class:"mb-5"}," Run Workflow ",-1)),n.value.workflowParams?(w(),E(F,{key:0,popup:!0,"workflow-param-data":n.value.workflowParams,"event-listener-yn":"N"},null,8,["workflow-param-data"])):x("",!0)]),t("div",Y,[a[2]||(a[2]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:a[0]||(a[0]=k=>s())}," Run ")])])])]))}}),tt={class:"modal",id:"workflowLog",tabindex:"-1"},ot={class:"modal-dialog modal-xl",role:"document"},st={class:"modal-content"},et={class:"modal-body text-left py-4"},at={class:"mb-5"},lt={key:0,class:"spinner-border",role:"status"},nt={key:0},rt={class:"card mb-3"},dt=["onClick"],it={class:"card-title"},ut={key:0,class:"card-body"},ct=["value"],wt=g({__name:"WorkflowLog",props:{workflowIdx:{}},emits:["get-oss-list"],setup(v,{emit:b}){y();const r=v,d=f(!1),i=I(()=>r.workflowIdx);$(i,async()=>{d.value=!1,await n()});const o=f([]),n=async()=>{o.value=[],await S(i.value).then(({data:k})=>{o.value=k,d.value=!0})},s=()=>{o.value=[],l.value=1},l=f(1),a=k=>{l.value===k?l.value=0:l.value=k};return(k,u)=>(w(),m("div",tt,[t("div",ot,[t("div",st,[u[3]||(u[3]=t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1)),t("div",et,[t("h3",at,[u[1]||(u[1]=V(" Workflow Log ")),d.value?x("",!0):(w(),m("div",lt,u[0]||(u[0]=[t("span",{class:"visually-hidden"},"Loading...",-1)])))]),t("div",null,[o.value.length<=0?(w(),m("div",nt,u[2]||(u[2]=[t("p",{class:"text-secondary"},"No Data",-1)]))):(w(!0),m(A,{key:1},G(o.value,e=>(w(),m("div",{key:e.buildIdx},[t("div",rt,[t("div",{class:"card-header",onClick:c=>a(e.buildIdx),style:{cursor:"pointer"}},[t("h3",it,W(e.buildIdx),1)],8,dt),l.value===e.buildIdx?(w(),m("div",ut,[t("textarea",{value:e.buildLog,disabled:"",style:{width:"100%"},rows:"20"},null,8,ct)])):x("",!0)])]))),128))])]),t("div",{class:"modal-footer"},[t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal",onClick:s}," Cancel ")])])])]))}}),mt={class:"card card-flush w-100"},pt=g({__name:"WorkflowList",setup(v){const b=f(!0);y();const r=f([]),d=f([]);T(async()=>{s(),await i()});const i=async()=>{try{b.value=!0,await B("N").then(({data:e})=>{b.value=!1,r.value=e})}catch(e){console.log(e)}},o=f(0),n=f(""),s=()=>{d.value=[{title:"Workflow Name",field:"workflowInfo.workflowName",width:"30%"},{title:"Workflow Purpose",field:"workflowInfo.workflowPurpose",width:"10%"},{title:"Status",field:"workflowInfo.status",width:"10%",formatter:k},{title:"Params Count",formatter:a,width:"10%"},{title:"Created Date",field:"regDate",width:"20%"},{title:"Action",width:"20%",formatter:u,cellClick:async(e,c)=>{const _=e.target,h=_==null?void 0:_.getAttribute("id");o.value=c.getRow().getData().workflowInfo.workflowIdx,h==="detail-btn"?C.push("/web/workflow/detail/"+o.value):h==="delete-btn"&&(n.value=c.getRow().getData().workflowInfo.workflowName)}}]},l=()=>{C.push("/web/workflow/new")},a=e=>`<span>${e._cell.row.data.workflowParams.length}</span>`,k=e=>{const c=e.getValue();return`
  <div>
    <span class="
      status
      ${c==="SUCCESS"?"status-green":c==="FAILED"?"status-red":c==="IN_PROGRESS"?"status-blue":""}" 
    >
      <span class="status-dot"></span>
      ${c}
    </span>
  </div>
  `},u=()=>`
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
    </div>`;return(e,c)=>{const _=O("b-overlay");return w(),m("div",mt,[p(N,{"header-title":"Workflow","new-btn-title":"New Workflow",popupFlag:!1,popupTarget:"",onClickNewBtn:l}),p(D,{columns:d.value,"table-data":r.value},null,8,["columns","table-data"]),p(H,{"workflow-name":n.value,"workflow-idx":o.value,onGetWorkflowList:i},null,8,["workflow-name","workflow-idx"]),p(Z,{"workflow-idx":o.value,onGetWorkflowList:i},null,8,["workflow-idx"]),p(wt,{"workflow-idx":o.value},null,8,["workflow-idx"]),p(_,{show:b.value,id:"overlay-background",variant:"transparent",opacity:"1",blur:"1rem",rounded:"lg",style:{"z-index":"1000"}},null,8,["show"])])}}});export{pt as default};
