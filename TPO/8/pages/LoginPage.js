const { By } = require("selenium-webdriver");
const BasePage = require("./BasePage");

class LoginPage extends BasePage {
    constructor(driver) {
        super(driver);

        this.username = By.id("userName");
        this.password = By.id("password");
        this.loginBtn = By.id("login");
        this.error = By.xpath("//*[@id='name']");
    }

    async open() {
        await super.open("https://demoqa.com/login");
    }

    async login(user, pass) {
        await this.type(this.username, user);
        await this.type(this.password, pass);
        await this.click(this.loginBtn);
    }

    async waitForError(timeout = 5000) {
        const el = await this.wait(this.error, timeout);
        return await el.getText();
    }

    async waitForNoError(timeout = 5000) {
        await this.driver.wait(async () => {
            const els = await this.driver.findElements(this.error);
            return els.length === 0;
        }, timeout);
    }
async waitForProfile() {
    await this.driver.wait(async () => {
        const url = await this.driver.getCurrentUrl();
        return url.includes("profile");
    }, 10000);
}
async isLoggedIn() {
    const url = await this.driver.getCurrentUrl();
    return url.includes("profile");
}
    async hasError() {
        const els = await this.driver.findElements(this.error);
        return els.length > 0;
    }
}

module.exports = LoginPage;
