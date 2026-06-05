const titleTest = require("./cases/titleTest");
const webTableTest = require("./cases/webTableTest");
const loginTest = require("./cases/loginTest");
const linksTest = require("./cases/linksTest");
const booksTest = require("./cases/booksTest");
const cookiesTest = require("./cases/cookiesTest");

module.exports = [

  {
    name: "TITLE TEST",
    tags: ["smoke"],
    skip: false,
    expectedFail: false,
    fn: titleTest
  },

  {
    name: "WEBTABLE TEST",
    tags: ["regression"],
    skip: false,
    expectedFail: false,
    fn: webTableTest
  },

  {
    name: "LOGIN TEST",
    tags: ["auth", "smoke"],
    skip: false,
    expectedFail: false,
    fn: loginTest
  },

  {
    name: "LINKS TEST",
    tags: ["links"],
    skip: true,
    expectedFail: false,
    fn: linksTest
  },

  {
    name: "BOOKS TEST",
    tags: ["books"],
    skip: false,
    expectedFail: true,
    fn: booksTest
  },

  {
    name: "COOKIES TEST",
    tags: ["cookies"],
    skip: false,
    expectedFail: false,
    fn: cookiesTest
  }

];
