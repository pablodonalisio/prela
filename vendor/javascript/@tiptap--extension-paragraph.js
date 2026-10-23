// @tiptap/extension-paragraph@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-paragraph@2.27.3/dist/index.js

import{Node as e,mergeAttributes as t}from"@tiptap/core";const n=e.create({name:`paragraph`,priority:1e3,addOptions(){return{HTMLAttributes:{}}},group:`block`,content:`inline*`,parseHTML(){return[{tag:`p`}]},renderHTML({HTMLAttributes:e}){return[`p`,t(this.options.HTMLAttributes,e),0]},addCommands(){return{setParagraph:()=>({commands:e})=>e.setNode(this.name)}},addKeyboardShortcuts(){return{"Mod-Alt-0":()=>this.editor.commands.setParagraph()}}});export{n as Paragraph,n as default};

