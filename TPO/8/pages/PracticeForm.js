const { By } = require("selenium-webdriver");
const BasePage = require("./BasePage");

class PracticeFormPage extends BasePage {
    constructor(driver) {
        super(driver);
        this.checkbox = By.css("input[type='checkbox']");
    }

    async open() {
        await super.open("https://demoqa.com/automation-practice-form");
    }

    async clickCheckbox() {
        let el = await this.find(this.checkbox);
        await el.click();
        return await el.isSelected();
    }
}

module.exports = PracticeFormPage;
