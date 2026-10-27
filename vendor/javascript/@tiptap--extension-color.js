// @tiptap/extension-color@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-color@2.27.3/dist/index.js

import"@tiptap/extension-text-style";import{Extension as e}from"@tiptap/core";const t=e.create({name:`color`,addOptions(){return{types:[`textStyle`]}},addGlobalAttributes(){return[{types:this.options.types,attributes:{color:{default:null,parseHTML:e=>{var t;return(t=e.style.color)==null?void 0:t.replace(/['"]+/g,``)},renderHTML:e=>e.color?{style:`color: ${e.color}`}:{}}}}]},addCommands(){return{setColor:e=>({chain:t})=>t().setMark(`textStyle`,{color:e}).run(),unsetColor:()=>({chain:e})=>e().setMark(`textStyle`,{color:null}).removeEmptyTextStyle().run()}}});export{t as Color,t as default};

