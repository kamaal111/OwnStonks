const Localize = require("./Localize.js/Localize");
const { keysFileTemplate, localizableFileTemplate } = require("./templates");
const en = require("./locales/en");

const DEFAULT_LOCALE = "en";

const locales = { en };

const main = () => {
  const localize = new Localize(
    "Packages/StonksLocale/Sources/StonksLocale/Resources",
    "Packages/StonksLocale/Sources/StonksLocale/Keys.swift",
    locales,
    DEFAULT_LOCALE,
    2
  );
  localize.setKeysTemplate(keysFileTemplate);
  localize.setLocaleFileTemplate(localizableFileTemplate);
  localize.generateFiles().then(console.log("Done localizing"));
};

main();
