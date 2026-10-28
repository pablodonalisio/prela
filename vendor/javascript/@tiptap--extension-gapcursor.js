// @tiptap/extension-gapcursor@2.27.3 downloaded from https://ga.jspm.io/npm:@tiptap/extension-gapcursor@2.27.3/dist/index.js

import{Extension as e,callOrReturn as t,getExtensionField as n}from"@tiptap/core";import{gapCursor as r}from"@tiptap/pm/gapcursor";const i=e.create({name:`gapCursor`,addProseMirrorPlugins(){return[r()]},extendNodeSchema(e){var r;return{allowGapCursor:(r=t(n(e,`allowGapCursor`,{name:e.name,options:e.options,storage:e.storage})))==null?null:r}}});export{i as Gapcursor,i as default};

