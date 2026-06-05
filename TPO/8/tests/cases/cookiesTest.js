const {
  assertEqual,
  assertTrue
} = require("../../utils/assert");

module.exports = async function(driver, browser) {

  await driver.get("https://demoqa.com");

  const cookies = await driver.manage().getCookies();

  console.log("\n===== COOKIES =====");

  cookies.forEach(cookie => {
    console.log(
      `${cookie.name} = ${cookie.value}`
    );
  });

  assertTrue(
    cookies.length > 0,
    `[${browser}] Куки успешно получены`
  );

  // ================= ADD COOKIE =================
  await driver.manage().addCookie({
    name: "test_cookie",
    value: "selenium_cookie_value"
  });

  const testCookie =
    await driver.manage().getCookie("test_cookie");

  assertEqual(
    testCookie.value,
    "selenium_cookie_value",
    `[${browser}] Cookie успешно добавлена`
  );
};
