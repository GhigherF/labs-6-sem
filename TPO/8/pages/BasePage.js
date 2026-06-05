const { until } = require("selenium-webdriver");

class BasePage {
    constructor(driver) {
        this.driver = driver;
        this.timeout = 10000;
    }

    async open(url) {
        await this.driver.get(url);
    }

    async find(locator) {
        return await this.driver.wait(
            until.elementLocated(locator),
            this.timeout
        );
    }

    async click(locator) {
        const el = await this.find(locator);
        await this.driver.executeScript("arguments[0].click()", el);
    }

    async type(locator, text) {
        const el = await this.find(locator);
        await el.clear();
        await el.sendKeys(text);
    }

    async getText(locator) {
        const el = await this.find(locator);
        return await el.getText();
    }

    async getAttr(locator, attr) {
        const el = await this.find(locator);
        return await el.getAttribute(attr);
    }

    async wait(locator, timeout = this.timeout) {
        return await this.driver.wait(
            until.elementLocated(locator),
            timeout
        );
    }
}

module.exports = BasePage;
