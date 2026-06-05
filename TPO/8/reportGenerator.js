const PDFDocument = require("pdfkit");
const fs = require("fs");

function generatePdfReport(results, browser, lang) {

  const doc = new PDFDocument({
    margin: 50
  });

  const fileName = `report_${browser}_${lang}.pdf`;

  doc.pipe(fs.createWriteStream(fileName));

  // ================= TITLE =================
  doc
    .font("Helvetica-Bold")
    .fontSize(22)
    .fillColor("black")
    .text("Selenium Test Report", {
      align: "center"
    });

  doc.moveDown();

  // ================= INFO =================
  doc
    .font("Helvetica")
    .fontSize(14)
    .fillColor("black");

  doc.text(`Browser: ${browser}`);
  doc.text(`Language: ${lang}`);
  doc.text(`Date: ${new Date().toLocaleString()}`);

  doc.moveDown();

  // ================= RESULTS =================
  results.forEach((test, index) => {

    // ---------- TEST TITLE ----------
    doc
      .font("Helvetica-Bold")
      .fontSize(16)
      .fillColor("black")
      .text(`${index + 1}. ${test.name}`);

    doc.moveDown(0.3);

    // ---------- STATUS COLOR ----------
    let color = "black";

    switch (test.status) {

      case "PASSED":
        color = "green";
        break;

      case "FAILED":
        color = "red";
        break;

      case "SKIPPED":
        color = "orange";
        break;

      case "EXPECTED FAIL":
        color = "blue";
        break;
    }

    // ---------- STATUS ----------
    doc
      .font("Helvetica-Bold")
      .fontSize(13)
      .fillColor(color)
      .text(`Status: ${test.status}`);

    // ---------- MESSAGE ----------
    if (test.message) {

      doc
        .font("Helvetica")
        .fontSize(11)
        .fillColor("black")
        .text(`Message: ${test.message}`);
    }

    // ---------- TAGS ----------
    if (test.tags) {

      doc
        .font("Helvetica-Oblique")
        .fontSize(11)
        .fillColor("gray")
        .text(`Tags: ${test.tags.join(", ")}`);
    }

    // ---------- DIVIDER ----------
    doc.moveDown(0.5);

    doc
      .strokeColor("#aaaaaa")
      .lineWidth(1)
      .moveTo(50, doc.y)
      .lineTo(550, doc.y)
      .stroke();

    doc.moveDown();
  });

  // ================= SUMMARY COUNTS =================
  const passed =
    results.filter(t => t.status === "PASSED").length;

  const failed =
    results.filter(t => t.status === "FAILED").length;

  const skipped =
    results.filter(t => t.status === "SKIPPED").length;

  const expectedFailed =
    results.filter(t => t.status === "EXPECTED FAIL").length;

  // ================= SUMMARY TITLE =================
  doc.moveDown();

  doc
    .font("Helvetica-Bold")
    .fontSize(20)
    .fillColor("black")
    .text("Summary");

  doc.moveDown(0.5);

  // ================= SUMMARY VALUES =================
  doc
    .font("Helvetica-Bold")
    .fillColor("green")
    .fontSize(13)
    .text(`Passed: ${passed}`);

  doc
    .font("Helvetica-Bold")
    .fillColor("red")
    .fontSize(13)
    .text(`Failed: ${failed}`);

  doc
    .font("Helvetica-Bold")
    .fillColor("orange")
    .fontSize(13)
    .text(`Skipped: ${skipped}`);

  doc
    .font("Helvetica-Bold")
    .fillColor("blue")
    .fontSize(13)
    .text(`Expected Fail: ${expectedFailed}`);

  // ================= FINISH PDF =================
  doc.end();

  console.log(`\nPDF report generated: ${fileName}`);
}

module.exports = {
  generatePdfReport
};
