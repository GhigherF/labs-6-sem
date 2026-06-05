const LoginPage = require("../../pages/LoginPage");

const {
  assertTrue
} = require("../../utils/assert");

module.exports = async function(driver, browser) {

  const login = new LoginPage(driver);

  await login.open();

  // ================= WRONG LOGIN =================
  await login.login("ghigher", "wrongpass");

  await login.waitForError();

  assertTrue(
    await login.hasError(),
    `[${browser}] Ошибка логина появляется`
  );

  // ================= VALID LOGIN =================
  await login.login("ghigher", "7412313aA$!");

  await login.waitForProfile();

  assertTrue(
    await login.isLoggedIn(),
    `[${browser}] Успешный вход`
  );
};
