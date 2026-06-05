const { By } = require("selenium-webdriver");
const BasePage = require("./BasePage");

class WebTablesPage extends BasePage {
    constructor(driver) {
        super(driver);

        this.search = By.id("searchBox");
        this.addBtn = By.css("#addNewRecordButton");
        this.header = By.css("h1");
    }

    async open() {
        await super.open("https://demoqa.com/webtables");
    }

    async searchText(text) {
        await this.type(this.search, text);
    }

    async getSearchValue() {
        return await this.getAttr(this.search, "value");
    }

    async getAddBtnText() {
        return await this.getText(this.addBtn);
    }

    async getHeaderText() {
        return await this.getText(this.header);
    }
}

module.exports = WebTablesPage;
