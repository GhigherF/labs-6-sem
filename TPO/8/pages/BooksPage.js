const { By, until } = require("selenium-webdriver");
const BasePage = require("./BasePage");

class BooksPage extends BasePage {
  constructor(driver) {
    super(driver);
    this.addBtn = By.xpath("//button[text()='Add To Your Collection']");
  }

  async open() {
    await super.open("https://demoqa.com/books?search=9781491904244");
  }

  async addBook() {
    const btn = await this.wait(this.addBtn, 15000);
    await this.driver.executeScript("arguments[0].click()", btn);

    await this.driver.wait(until.alertIsPresent(), 10000);

    const alert = await this.driver.switchTo().alert();
    const text = await alert.getText();
    await alert.accept();

    return text;
  }
}

module.exports = BooksPage;
