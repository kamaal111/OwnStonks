const fs = require("fs");

const { promises: asyncFS } = fs;

const defaultLocale = "en";

const en = {
  PORTFOLIO_SCREEN_TITLE: "Portfolio",
};

const locales = { en };

function generateFileInput(locale, returnKeysInput = false) {
  const localeEntries = Object.entries(locale);
  let fileInput = "";
  let keysTemplateInput = "";
  for (let index = 0; index < localeEntries.length; index++) {
    const [key, translation] = localeEntries[index];
    fileInput += `"${key}" = "${translation}";`;
    if (returnKeysInput) {
      keysTemplateInput += `case ${key}${
        index < localeEntries.length - 1 ? "\n" : ""
      }`;
    }
  }
  return { fileInput, keysTemplateInput };
}

function keysFileTemplate(input) {
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
}

function localizableFileTemplate(input) {
  return `/*
  Localizable.strings

  Created by Kamaal M Farah on 04/04/2021.

*/

${input}
`;
}

async function createLocaleFiles(localesKey) {
  const locale = locales[localesKey];
  const generateKeysInput = localesKey === defaultLocale;
  const {
    fileInput: localizableFileInput,
    keysTemplateInput,
  } = generateFileInput(locale, generateKeysInput);
  if (generateKeysInput) {
    const keysFilePath = `Packages/StonksLocale/Sources/StonksLocale/Keys.swift`;
    await asyncFS.writeFile(keysFilePath, keysFileTemplate(keysTemplateInput));
  }
  const pathToLocalizableDirectory = `Packages/StonksLocale/Sources/StonksLocale/Resources/${localesKey}.lproj`;
  if (!fs.existsSync(pathToLocalizableDirectory)) {
    await asyncFS.mkdir(pathToLocalizableDirectory);
  }
  const pathToLocalizableFile = `${pathToLocalizableDirectory}/Localizable.strings`;
  await asyncFS.writeFile(
    pathToLocalizableFile,
    localizableFileTemplate(localizableFileInput)
  );
}

async function main() {
  console.time("Done in");
  Promise.all(Object.keys(locales).map(createLocaleFiles))
    .catch(console.error)
    .finally(() => console.timeEnd("Done in"));
}

main();
