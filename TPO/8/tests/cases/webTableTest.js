const WebTablesPage = require("../../pages/WebTablesPage");

const {
  assertEqual,
  assertTrue
} = require("../../utils/assert");

module.exports = async function(driver, browser) {

  const table = new WebTablesPage(driver);

  await table.open();

  const text = "Тестирование поля для ввода текста";

  await table.searchText(text);

  assertEqual(
    await table.getSearchValue(),
    text,
    `[${browser}] Корректная работа поля ввода`
  );

  assertTrue(
    (await table.getHeaderText()).length > 0,
    `[${browser}] Заголовок существует`
  );

  assertTrue(
    (await table.getAddBtnText()).length > 0,
    `[${browser}] Кнопка Add существует`
  );
};
