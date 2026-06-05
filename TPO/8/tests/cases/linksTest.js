const { By } = require("selenium-webdriver");

const {
  assertTrue
} = require("../../utils/assert");

module.exports = async function(driver, browser) {

  await driver.get("https://demoqa.com/links");

  const links = await driver.findElements(
    By.xpath('//*[@id="linkWrapper"]/p')
  );

  assertTrue(
    links.length > 0,
    `[${browser}] Ссылки найдены`
  );
};
