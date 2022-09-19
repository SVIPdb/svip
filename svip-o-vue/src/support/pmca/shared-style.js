const sharedStyle = document.createElement('dom-module');
sharedStyle.innerHTML = `<template>
    <style>

    button {
      font-family: inherit;
      background-color: lightgray;
      border-style: solid;
      border-width: thin;
      border-color: lightgray;
      background-color: inherit;
      color: gray;
      border-radius:5px;
      padding: 4px 15px;
      text-align: center;
      font-size: inherit;
      cursor: pointer;
    }
    button:hover {
      background-color: gray;
      color: white;
    }
    input {
      border-style: solid;
      border-width: thin;
      border-color: lightgray;
      padding: 3px 10px;
      font-size: inherit;
    }

    .publi-debug-info {
      font-size: 9px;
      font-weight: normal;
      border: 1px solid lightgray;
      background-color: hsl(81, 81%, 75%);
    }

    .publi-debug-info-hidden {
      display:none;
    }

    .publi-contents-wrapper {
      #margin-block-start: 2.5em;
      #margin-block-end: 0.0em;
      margin-bottom: 0.5em;
    }

    .publi-link-style {
      font-size: 12px;
      margin-bottom: 1.0em;
      text-decoration: none;
    }

    .publi-label-style {
      font-weight: bold;
      margin-top: 0.50em;
      margin-bottom: 1.50em;
    }

    .publi-caption-style {
      font-size: 14px;
      font-style: normal;
      font-family: Arial, Serif;
      margin-top: 1.5em;
      margin-bottom: 0.5em;
    }

    .publi-footer-style {
      font-size: 11px;
      font-style: normal;
      font-family: Arial, Serif;
      margin-top: 1.5em;
      margin-bottom: 0.5em;
    }

    .publi-figure-wrapper {
      border: solid 1px lightgray;
      background-color: lightyellow;
      display: block;
      #display: inline-block;
      padding:15px;
      margin-top:20px;
      margin-bottom:20px;
    }

    .publi-table-wrapper {
      border: solid 1px lightgray;
      background-color: lightyellow;
      display: inline-block;
      #display: block;
      padding:15px;
      margin-top:20px;
      margin-bottom:20px;
    }

    .publi-list-item-wrapper {
      display: inline-block;
      padding-left:30px;
    }

    .publi-table-style td {
      font-size:13px;
      padding-left: 7px;
      padding-right: 7px;
    }

    .publi-table-style th {
      font-size:13px;
      padding-left: 7px;
      padding-right: 7px;
    }


    .publi-title {
      color: blue;
      font-size:24px;
      font-weight: bold;
      font-family: Arial, Serif;
      margin-top:1.2em;
      margin-bottom:0.8em;

    }

    .publi-h1 {
      font-size:20px;
      font-weight: bold;
      font-family: Arial, Serif;
      margin-top:1.25em;
      margin-bottom:0.63em;
    }

    .publi-h2 {
      font-size:18px;
      font-weight: bold;
      font-family: Arial, Serif;
      margin-top:1.00em;
      margin-bottom:0.50em;
    }

    .publi-h3 {
      font-size:16px;
      font-weight: bold;
      font-family: Arial, Serif;
      margin-top:0.66em;
      margin-bottom:0.50em;

    }

    .publi-h4 {
      font-size:16px;
      font-weight: normal;
      font-family: Arial, Serif;
      margin-top:0.5em;
      margin-bottom:0.25em;
    }

    .publi-affiliation-label {
      display: inline-block;
      width: 10px;
      font-size: 11px;
    }

    .publi-para {
      font-size: 16px;
      line-height: 1.5;
      font-family: 'Times New Roman', 'sans-serif';
    }


    </style>
  </template>`;
sharedStyle.register('shared-style');
