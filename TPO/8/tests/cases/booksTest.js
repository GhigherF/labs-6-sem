const BooksPage = require("../../pages/BooksPage");

const {
  assertIncludes
} = require("../../utils/assert");

module.exports = async function(driver, browser) {

  const books = new BooksPage(driver);

  await books.open();

  const alertText = await books.addBook();

  assertIncludes(
    alertText.toLowerCase(),
    "success",
    `[${browser}] Добавление книги`
  );
};
