const Localize = require("./Localize");

const defaultLocale = "en";

const en = {
  PORTFOLIO_SCREEN_TITLE: "Portfolio",
};

const locales = { en };

const keysFileTemplate = (input) => {
  return `//
//  Keys.swift
//  
//
//  Created by Kamaal M Farah on 07/05/2021.
//

extension StonksLocale {
    public enum Keys: String {
        ${input}
    }
}
`;
};

const localizableFileTemplate = (input) => {
  return `/*
  Localizable.strings

  Created by Kamaal M Farah on 07/05/2021.

*/

${input}
`;
};

const localize = new Localize(
  "Packages/StonksLocale/Sources/StonksLocale/Resources",
  "Packages/StonksLocale/Sources/StonksLocale/Keys.swift",
  locales,
  defaultLocale
);
localize.setKeysTemplate(keysFileTemplate);
localize.setLocaleFileTemplate(localizableFileTemplate);
localize.generateFiles();
