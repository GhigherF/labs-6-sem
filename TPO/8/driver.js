const selenium = require("selenium-webdriver");

const chrome = require("selenium-webdriver/chrome");
const edge = require("selenium-webdriver/edge");

async function buildDriver(browser = "chrome", lang = "en") {

  let builder = new selenium.Builder();

  if (browser === "chrome") {

    const options = new chrome.Options();

    options.setChromeBinaryPath(
      "C:\\Users\\ghigh\\AppData\\Local\\Thorium\\Application\\thorium.exe"
    );

    options.addArguments("--start-maximized");
    options.addArguments("--disable-notifications");

    options.addArguments(`--lang=${lang}`);

    builder
      .forBrowser("chrome")
      .setChromeOptions(options);
  }

  else if (browser === "edge") {

    const options = new edge.Options();

    options.addArguments("--start-maximized");
    options.addArguments("--disable-notifications");

    options.addArguments(`--lang=${lang}`);

    builder
      .forBrowser("MicrosoftEdge")
      .setEdgeOptions(options);
  }

  const driver = await builder.build();

  await driver.manage().setTimeouts({
    implicit: 5000,
    pageLoad: 15000,
    script: 10000
  });

  return driver;
}

module.exports = { buildDriver };
