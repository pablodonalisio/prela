// @tiptap/extension-history@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-history@2.27.3/dist/index.js

import{Extension as e}from"@tiptap/core";import{history as t,redo as n,undo as r}from"@tiptap/pm/history";const i=e.create({name:`history`,addOptions(){return{depth:100,newGroupDelay:500}},addCommands(){return{undo:()=>({state:e,dispatch:t})=>r(e,t),redo:()=>({state:e,dispatch:t})=>n(e,t)}},addProseMirrorPlugins(){return[t(this.options)]},addKeyboardShortcuts(){return{"Mod-z":()=>this.editor.commands.undo(),"Shift-Mod-z":()=>this.editor.commands.redo(),"Mod-y":()=>this.editor.commands.redo(),"Mod-я":()=>this.editor.commands.undo(),"Shift-Mod-я":()=>this.editor.commands.redo()}}});export{i as History,i as default};

