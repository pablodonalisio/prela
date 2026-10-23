// @tiptap/extension-list-item@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-list-item@2.27.3/dist/index.js

import{Node as e,mergeAttributes as t}from"@tiptap/core";const n=e.create({name:`listItem`,addOptions(){return{HTMLAttributes:{},bulletListTypeName:`bulletList`,orderedListTypeName:`orderedList`}},content:`paragraph block*`,defining:!0,parseHTML(){return[{tag:`li`}]},renderHTML({HTMLAttributes:e}){return[`li`,t(this.options.HTMLAttributes,e),0]},addKeyboardShortcuts(){return{Enter:()=>this.editor.commands.splitListItem(this.name),Tab:()=>this.editor.commands.sinkListItem(this.name),"Shift-Tab":()=>this.editor.commands.liftListItem(this.name)}}});export{n as ListItem,n as default};

