import{_ as F}from"./TableHeader.vue_vue_type_script_setup_true_lang-B6ZW24wQ.js";import{_ as R}from"./request-kG1J30_C.js";import{d as B,P as E,j as S,b as V,e as A,c as G}from"./ParamForm-BR-fyMRf.js";import{k as y,E as h,h as k,e as t,z as $,t as w,J as L,f as T,g as x,v as f,d as N,i as U,F as j,w as z,s as O,r as J,y as I,j as _,x as M}from"./index-C8GccX-2.js";const q={class:"modal modal-blur fade",id:"deleteWorkflow",tabindex:"-1","aria-hidden":"true"},H={class:"modal-dialog modal-lg modal-dialog-centered",role:"document"},K={class:"modal-content"},Q={class:"modal-body py-4"},X={class:"modal-footer"},Y=y({__name:"DeleteWorkflow",props:{workflowName:{},workflowIdx:{}},emits:["get-workflow-list"],setup(p,{emit:b}){const r=h(),d=p,i=b,e=async()=>{const{data:c}=await B(d.workflowIdx);c?r.success("삭제되었습니다."):r.error("삭제하지 못했습니다."),i("get-workflow-list")};return(c,o)=>(w(),k("div",q,[t("div",H,[t("div",K,[o[2]||(o[2]=t("div",{class:"modal-status bg-danger"},null,-1)),o[3]||(o[3]=t("div",{class:"modal-header"},[t("h3",{class:"modal-title"},"Delete Workflow"),t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"})],-1)),t("div",Q,[t("h4",null,"Are you sure you want to delete "+$(d.workflowName)+"?",1)]),t("div",X,[o[1]||(o[1]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:o[0]||(o[0]=l=>e())}," Delete ")])])])]))}}),Z={class:"modal modal-blur fade",id:"runWorkflow",tabindex:"-1","aria-hidden":"true"},tt={class:"modal-dialog modal-lg modal-dialog-centered",role:"document"},ot={class:"modal-content"},st={class:"modal-body py-4"},et={class:"modal-footer"},at=y({__name:"RunWorkflow",props:{workflowIdx:{}},emits:["get-workflow-list"],setup(p,{emit:b}){const r=h(),d=p,i=b,e=N(()=>d.workflowIdx),c=f({}),o=f(!1);L(()=>e.value,async()=>{const{data:a}=await V(e.value,"N");c.value=a});const l=async()=>{if(!o.value){o.value=!0;try{const{data:a}=await S(c.value);a?r.success("워크플로우 실행 요청이 접수되었습니다."):r.error("워크플로우 실행 요청을 처리하지 못했습니다."),i("get-workflow-list")}catch(a){console.log(a),r.error("워크플로우 실행 요청을 처리하지 못했습니다.")}finally{o.value=!1}}};return(a,s)=>(w(),k("div",Z,[t("div",tt,[t("div",ot,[s[2]||(s[2]=t("div",{class:"modal-status bg-info"},null,-1)),s[3]||(s[3]=t("div",{class:"modal-header"},[t("h3",{class:"modal-title"},"Run Workflow"),t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"})],-1)),t("div",st,[c.value.workflowParams?(w(),T(E,{key:0,popup:!0,"workflow-param-data":c.value.workflowParams,"event-listener-yn":"N"},null,8,["workflow-param-data"])):x("",!0)]),t("div",et,[s[1]||(s[1]=t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal"}," Cancel ",-1)),t("a",{href:"#",class:"btn btn-primary ms-auto","data-bs-dismiss":"modal",onClick:s[0]||(s[0]=u=>l())}," Run ")])])])]))}}),lt={class:"modal",id:"workflowLog",tabindex:"-1"},nt={class:"modal-dialog modal-xl",role:"document"},rt={class:"modal-content"},dt={class:"modal-body text-left py-4"},it={class:"mb-5"},ct={key:0,class:"spinner-border",role:"status"},ut={key:0},wt={class:"card mb-3"},ft=["onClick"],mt={class:"card-title"},kt={key:0,class:"card-body"},bt=["value"],vt=y({__name:"WorkflowLog",props:{workflowIdx:{}},emits:["get-oss-list"],setup(p,{emit:b}){h();const r=p,d=f(!1),i=N(()=>r.workflowIdx);L(i,async()=>{d.value=!1,await c()});const e=f([]),c=async()=>{e.value=[],await A(i.value).then(({data:s})=>{e.value=s,d.value=!0})},o=()=>{e.value=[],l.value=1},l=f(1),a=s=>{l.value===s?l.value=0:l.value=s};return(s,u)=>(w(),k("div",lt,[t("div",nt,[t("div",rt,[u[3]||(u[3]=t("button",{type:"button",class:"btn-close","data-bs-dismiss":"modal","aria-label":"Close"},null,-1)),t("div",dt,[t("h3",it,[u[1]||(u[1]=U(" Workflow Log ",-1)),d.value?x("",!0):(w(),k("div",ct,[...u[0]||(u[0]=[t("span",{class:"visually-hidden"},"Loading...",-1)])]))]),t("div",null,[e.value.length<=0?(w(),k("div",ut,[...u[2]||(u[2]=[t("p",{class:"text-secondary"},"No Data",-1)])])):(w(!0),k(j,{key:1},z(e.value,v=>(w(),k("div",{key:v.buildIdx},[t("div",wt,[t("div",{class:"card-header",onClick:C=>a(v.buildIdx),style:{cursor:"pointer"}},[t("h3",mt,$(v.buildIdx),1)],8,ft),l.value===v.buildIdx?(w(),k("div",kt,[t("textarea",{value:v.buildLog,disabled:"",style:{width:"100%"},rows:"20"},null,8,bt)])):x("",!0)])]))),128))])]),t("div",{class:"modal-footer"},[t("a",{href:"#",class:"btn btn-link link-secondary","data-bs-dismiss":"modal",onClick:o}," Cancel ")])])])]))}}),pt={class:"card card-flush w-100"},_t={class:"card-body"},Ct=y({__name:"WorkflowList",setup(p){const b=f(!0);h();const r=f([]),d=f([]);O(async()=>{u(),await l(),c()}),J(()=>{o()});let i,e=!1;const c=()=>{o(),i=setInterval(()=>{l(!1)},5e3)},o=()=>{i&&(clearInterval(i),i=void 0)},l=async(m=!0)=>{if(!e){e=!0;try{m&&(b.value=!0),await G("N").then(({data:n})=>{r.value=n})}catch(n){console.log(n)}finally{m&&(b.value=!1),e=!1}}},a=f(0),s=f(""),u=()=>{d.value=[{title:"Workflow Name",field:"workflowInfo.workflowName",width:"30%"},{title:"Workflow Purpose",field:"workflowInfo.workflowPurpose",width:"10%"},{title:"Status",field:"workflowInfo.status",width:"10%",formatter:D},{title:"Params Count",formatter:C,width:"10%"},{title:"Created Date",field:"regDate",width:"20%"},{title:"Action",width:"20%",formatter:P,cellClick:async(m,n)=>{const g=m.target,W=g==null?void 0:g.getAttribute("id");a.value=n.getRow().getData().workflowInfo.workflowIdx,W==="detail-btn"?I.push("/web/workflow/detail/"+a.value):W==="delete-btn"&&(s.value=n.getRow().getData().workflowInfo.workflowName)}}]},v=()=>{I.push("/web/workflow/new")},C=m=>`<span>${m._cell.row.data.workflowParams.length}</span>`,D=m=>{const n=m.getValue();return`
  <div>
    <span class="
      status
      ${n==="SUCCESS"?"status-green":n==="FAILED"?"status-red":n==="IN_PROGRESS"?"status-blue":""}" 
    >
      <span class="status-dot"></span>
      ${n}
    </span>
  </div>
  `},P=()=>`
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
    </div>`;return(m,n)=>{const g=M("b-overlay");return w(),k("div",null,[_(F,{"header-title":"Workflow","new-btn-title":"New Workflow","popup-flag":!1,"popup-target":"",class:"mb-3",onClickNewBtn:v}),t("div",pt,[t("div",_t,[_(R,{columns:d.value,"table-data":r.value},null,8,["columns","table-data"])])]),_(Y,{"workflow-name":s.value,"workflow-idx":a.value,onGetWorkflowList:l},null,8,["workflow-name","workflow-idx"]),_(at,{"workflow-idx":a.value,onGetWorkflowList:l},null,8,["workflow-idx"]),_(vt,{"workflow-idx":a.value},null,8,["workflow-idx"]),_(g,{show:b.value,id:"overlay-background",variant:"transparent",opacity:"1",blur:"1rem",rounded:"lg",style:{"z-index":"1000"}},null,8,["show"])])}}});export{Ct as default};
