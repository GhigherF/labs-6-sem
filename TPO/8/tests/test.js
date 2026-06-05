const { buildDriver } = require("../driver");
const { generatePdfReport } = require("../reportGenerator");

const tests = require("./testsList");

(async () => {

  const browser = process.argv[2] || "chrome";
  const lang = process.argv[3] || "en";

  const onlyTag = process.argv[4];

  console.log(`\n===== TEST RUNNER =====`);
  console.log(`Browser: ${browser}`);
  console.log(`Language: ${lang}`);

  if (onlyTag) {
    console.log(`Tag filter: ${onlyTag}`);
  }

  const driver = await buildDriver(browser, lang);

  const results = [];

  try {

    for (const test of tests) {

      if (onlyTag && !test.tags.includes(onlyTag)) {
        continue;
      }

      if (test.skip) {

        console.log(`\n>> SKIPPED: ${test.name}`);

        results.push({
          name: test.name,
          status: "SKIPPED",
          tags: test.tags
        });

        continue;
      }

      console.log(`\n > RUNNING: ${test.name}`);

      try {

        // ===================== RUN TEST =====================
        await test.fn(driver, browser);

        // ===================== EXPECTED FAIL DID NOT FAIL =====================
        if (test.expectedFail) {

          console.log(`⚠ EXPECTED FAIL DID NOT FAIL`);

          results.push({
            name: test.name,
            status: "FAILED",
            message: "Expected fail did not fail",
            tags: test.tags
          });

        } else {

          console.log(`[PASSED]: ${test.name}`);

          results.push({
            name: test.name,
            status: "PASSED",
            tags: test.tags
          });
        }

      } catch (e) {

        if (test.expectedFail) {

          console.log(`[EXPECTED FAIL]: ${test.name}`);
          console.log(`Reason: ${e.message}`);

          results.push({
            name: test.name,
            status: "EXPECTED FAIL",
            message: e.message,
            tags: test.tags
          });

        } else {

          console.log(`[FAILED] : ${test.name}`);
          console.log(`Reason: ${e.message}`);

          results.push({
            name: test.name,
            status: "FAILED",
            message: e.message,
            tags: test.tags
          });
        }
      }
    }

  } finally {

    generatePdfReport(results, browser, lang);

    await driver.quit();
  }

})();
