// @tiptap/extension-dropcursor@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-dropcursor@2.27.3/dist/index.js

import{Extension as e}from"@tiptap/core";import{dropCursor as t}from"@tiptap/pm/dropcursor";const n=e.create({name:`dropCursor`,addOptions(){return{color:`currentColor`,width:1,class:void 0}},addProseMirrorPlugins(){return[t(this.options)]}});export{n as Dropcursor,n as default};

