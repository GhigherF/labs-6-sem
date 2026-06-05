const selenium = require("selenium-webdriver");
const chrome = require('selenium-webdriver/chrome');


(async () => {


    let options = new chrome.Options();
    options.setChromeBinaryPath("C:\\Users\\ghigh\\AppData\\Local\\Thorium\\Application\\thorium.exe");
    let driver = await new selenium.Builder().forBrowser("chrome").setChromeOptions(options).build();



    try {



        await driver.get("https://demoqa.com/accordian");
        console.log(`Title: ${await driver.getTitle()}`)
        
        ////////////////////////////ID////////////////////////////////////////
        console.log("---ID----------------------------------")
        let ad =  await driver.findElement(selenium.By.id("RightSide_Advertisement"));
        let addSize = await ad.getRect();
        console.log(`Размер окна для рекламы: ${addSize.width}X${addSize.height}`);

        await driver.get("https://demoqa.com/webtables")

        let search =  await driver.findElement(selenium.By.id("searchBox"));
        await search.sendKeys('Тестирование поля для ввода текста');
        console.log(`Текст в input-поле: ${await search.getAttribute('value')}`)
        //await driver.sleep(4000);

        
        //////////////////////////CSS//////////////////////////////////////////////
        console.log("---CSS----------------------------------")
        let addButton = await driver.findElement(selenium.By.css('div div div div div #addNewRecordButton'));
        console.log(`Текст кнопки для добавления: ${await addButton.getText()}`);


        let tableHeader = await driver.findElement(selenium.By.css('div div div div div div div h1'));
        console.log(`Текст заголовка перед таблицей: ${await tableHeader.getText()}`);
        
        ///////////////////////////////////////////////////////////////////////////

        

        //////////////////////////X-PATH//////////////////////////////////////////////
        console.log("---XPath----------------------------------")

        let bookStoreSvg = await driver.findElement(selenium.By.xpath("//*[@id='root']/div/div/div/div[1]/div/div/div[6]/span/div/div[1]/span/*[name()='svg']"));
        console.log(`Спецификация SVG: ${await bookStoreSvg.getAttribute('xmlns')}`)
        
        let siteIcon = await driver.findElement(selenium.By.xpath('//*[@id="root"]/header/a/img'));
        console.log(`Статический файл иконки: ${await siteIcon.getAttribute('src')}`);
        ///////////////////////////////////////////////////////////////////////////


        ///////////////////////// Частичный текст ссылки  ////////////////////////////////////////
        console.log("---   Частичный текст ссылки  ----------------------------------")
        await driver.get("https://demoqa.com/automation-practice-form");
        
        let a = await driver.findElement(selenium.By.partialLinkText('Practice'));
        console.log(`Ссылка : ${await a.getAttribute('href')}`)
        ////////////////////////////////////////////////////////////////////////////////


        ///////////////////////// Несколько элементов  ////////////////////////////////////////
        console.log("---   Несколько элементов  ----------------------------------")
        await driver.get("https://demoqa.com/links");

        let list = await driver.findElements(selenium.By.xpath('//*[@id="linkWrapper"]/p'));
        console.log("Список ссылок:");
        for (link of list){
            console.log(await link.getText())
        }
        ////////////////////////////////////////////////////////////////////////////////





        //////////////////////////////  Авторизация ////////////////////////////////////////////
        await driver.get("https://demoqa.com/login");
        
        
        console.log("--- Авторизация -----------------------------------------------")
        console.log("-- 1 ----------");
        console.log(`Ожидается: сообщение об ошибке`);
        
        try {
        let username = await driver.findElement(selenium.By.id("userName"));
        let password = await driver.findElement(selenium.By.id("password"));
        let login = await driver.findElement(selenium.By.id("login"));
        await username.sendKeys("ghigher");
        await password.sendKeys("7412313aA$");
        //await driver.sleep(1000);
        await login.click();
        let error = await driver.wait(selenium.until.elementLocated(selenium.By.xpath(`//*[@id="name"]`)),5000);
         console.log(`Получено: ${await error.getText()}`);
        }
        catch{console.log("Получено: сообщение об ошибке НЕ ПОЛУЧЕНО")};
        console.log("-- 2 ----------");
        console.log("Ожидается: отсутствие сообщения об ошибке");         

        try {
        username = await driver.findElement(selenium.By.id("userName"));
        password = await driver.findElement(selenium.By.id("password"));
        login = await driver.findElement(selenium.By.id("login"));
        await username.clear();
        await username.sendKeys("ghigher");
        await password.clear();
        await password.sendKeys("7412313aA$!");
        //await driver.sleep(1000);
        await login.click();
        let eror = await driver.wait(selenium.until.elementLocated(selenium.By.xpath(`//*[@id="name"]`)),5000);
         console.log(`Получено: ${await error.getText()}`);
        }
        catch{console.log("Получено: сообщение об ошибке НЕ ПОЛУЧЕНО")};
        /////////////////////////////////////////////////////////////////////////////////////////////


        ///////////////////////////  2 Тест-кейса   ///////////////////////////////////////

        await driver.get("https://demoqa.com/swagger#/BookStore/BookStoreV1BooksPost");
        let tryButton = await driver.wait(selenium.until.elementLocated(selenium.By.xpath("//button[@class='btn try-out__btn']")),7000);
        await driver.executeScript("arguments[0].click();",tryButton);
 
        let executeButton = await driver.wait(selenium.until.elementLocated(selenium.By.xpath("//button[@class='btn execute opblock-control__btn']")),7000);
        await driver.executeScript("arguments[0].click();",executeButton);

        //await driver.sleep(500);
        console.log("-------  Тест-кейсы ----------------------------------------")
        console.log("--- 1 ------------");
        console.log('Ожидаемый результат: 401 Unauthorized');
        //await driver.sleep(500);

        let statusCode = await driver.wait(selenium.until.elementLocated(selenium.By.xpath('/html/body/div/section/div[2]/div[2]/div[4]/section/div/span[2]/div/div/div/span[2]/div/div[2]/div/div[3]/div[2]/div/div/table/tbody/tr/td[1]')),4000)
        let statusMsg = await driver.wait(selenium.until.elementLocated(selenium.By.xpath('//*[@id="operations-BookStore-BookStoreV1BooksPost"]/div[2]/div/div[3]/div[2]/div/div/table/tbody/tr/td[2]/div[1]/p')),500)
        console.log(`Получено: ${await statusCode.getText()} ${await statusMsg.getText()}`)

        


        driver.get("https://demoqa.com/automation-practice-form");
        const checkbox = await driver.findElement(selenium.By.css("input[type='checkbox']"));
        await driver.sleep(1000);
        await checkbox.click();
        await driver.sleep(1000);
        console.log("--- 2 ------------");
        console.log(`Ожидаемое состояние: выбрано\n Получено:${(await checkbox.isSelected())?"Выбрано":"Не выбрано"}`);
        ////////////////////////////////////////////////////////////////////////////




        ///////////////////////////// Сквозное тестирование  ///////////////////////////////////////


        // Авторизация через UI
        await driver.get("https://demoqa.com/login");
        let username = await driver.findElement(selenium.By.id("userName"));
        let password = await driver.findElement(selenium.By.id("password"));
        let loginBtn = await driver.findElement(selenium.By.id("login"));
        await username.sendKeys("ghigher");
        await password.sendKeys("7412313aA$!");
        await driver.executeScript("arguments[0].click();", loginBtn);
        await driver.sleep(3000);
        console.log('Current URL after login:', await driver.getCurrentUrl());

        await driver.get("https://demoqa.com/books?search=9781491904244");

addButton = await driver.wait(
    selenium.until.elementLocated(
        selenium.By.xpath("//button[text()='Add To Your Collection']")
    ),
    15000
);

await driver.executeScript("arguments[0].click();", addButton);

await driver.sleep(2000);

await driver.wait(selenium.until.alertIsPresent(), 15000);

const alert = await driver.switchTo().alert();
console.log(await alert.getText());
console.log('Ожидается: Добавлено успешно')
console.log("Получено: ", await alert.getText());
await alert.accept();
    }
  catch (e) {
        console.error(e);
    }
    finally {
        await driver.quit();
    }
})()
