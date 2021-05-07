const Localize = require("./Localize.js/Localize");
const { keysFileTemplate, localizableFileTemplate } = require("./templates");
const en = require("./locales/en");

const defaultLocale = "en";

const locales = { en };

const localize = new Localize(
  "Packages/StonksLocale/Sources/StonksLocale/Resources",
  "Packages/StonksLocale/Sources/StonksLocale/Keys.swift",
  locales,
  defaultLocale,
  2
);
localize.setKeysTemplate(keysFileTemplate);
localize.setLocaleFileTemplate(localizableFileTemplate);
localize.generateFiles();
