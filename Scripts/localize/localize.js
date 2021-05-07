const fs = require("fs");

const { promises: asyncFS } = fs;

const en = {
  PORTFOLIO_SCREEN_TITLE: "Portfolio",
};

const locales = { en };

function generateFileInput(locale) {
  const localeEntries = Object.entries(locale);
  let fileInput = "";
  for (let index = 0; index < localeEntries.length; index++) {
    const [key, translation] = localeEntries[index];
    fileInput += `"${key}" = "${translation}";`;
  }
  return fileInput;
}

async function createLocaleFile(localesKey) {
  const locale = locales[localesKey];
  const localizableFileInput = generateFileInput(locale);
  const pathToLocalizableDirectory = `Packages/StonksLocale/Sources/StonksLocale/Resources/${localesKey}.lproj`;
  if (!fs.existsSync(pathToLocalizableDirectory)) {
    await asyncFS.mkdir(pathToLocalizableDirectory);
  }
  const pathToLocalizableFile = `${pathToLocalizableDirectory}/Localizable.strings`;
  await asyncFS.writeFile(pathToLocalizableFile, localizableFileInput);
}

async function main() {
  console.time("Done in");
  Promise.all(Object.keys(locales).map(createLocaleFile))
    .catch(console.error)
    .finally(() => console.timeEnd("Done in"));
}

main();
