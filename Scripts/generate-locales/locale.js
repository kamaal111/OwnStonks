const Localize = require("@kamaal111/localize");
const en = require("../../Locales/en");

const DEFAULT_LOCALE = "en";

const locales = { en };

const keysFileTemplate = (input) => {
  return `//
//  Keys.swift
//
//
//  Created by Kamaal M Farah on 28/12/2022.
//

extension OSLocales {
    public enum Keys: String {
${input}
    }
}
`;
};

const localizableFileTemplate = (input) => {
  return `/*
  Localizable.strings
  OSLocales

  Created by Kamaal Farah on 28/12/2022.
  Copyright © 2022 Kamaal. All rights reserved.
*/

${input}
`;
};

const main = () => {
  const localize = new Localize(
    "Packages/OSLocales/Sources/OSLocales/Resources",
    "Packages/OSLocales/Sources/OSLocales/Keys.swift",
    locales,
    DEFAULT_LOCALE,
    2
  );
  localize.setKeysTemplate(keysFileTemplate);
  localize.setLocaleFileTemplate(localizableFileTemplate);
  localize.generateFiles().then(console.log("Done localizing"));
};

main();
