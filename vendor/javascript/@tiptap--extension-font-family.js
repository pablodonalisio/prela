// @tiptap/extension-font-family@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-font-family@2.27.3/dist/index.js

import"@tiptap/extension-text-style";import{Extension as e}from"@tiptap/core";const t=e.create({name:`fontFamily`,addOptions(){return{types:[`textStyle`]}},addGlobalAttributes(){return[{types:this.options.types,attributes:{fontFamily:{default:null,parseHTML:e=>e.style.fontFamily,renderHTML:e=>e.fontFamily?{style:`font-family: ${e.fontFamily}`}:{}}}}]},addCommands(){return{setFontFamily:e=>({chain:t})=>t().setMark(`textStyle`,{fontFamily:e}).run(),unsetFontFamily:()=>({chain:e})=>e().setMark(`textStyle`,{fontFamily:null}).removeEmptyTextStyle().run()}}});export{t as FontFamily,t as default};

