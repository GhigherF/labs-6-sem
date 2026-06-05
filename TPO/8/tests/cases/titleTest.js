const { assertTrue } = require("../../utils/assert");

module.exports = async function(driver, browser) {

  await driver.get("https://demoqa.com/accordian");

  const title = await driver.getTitle();

  assertTrue(
    title.length > 0,
    `[${browser}] Title не пустой`
  );
};
