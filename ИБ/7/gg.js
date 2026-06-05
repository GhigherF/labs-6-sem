const crypto = require("crypto");
const fs = require("fs");

// =========================
// BLOCK SIZE
// =========================
const BLOCK_SIZE = 8;

// =========================
// TEXT
// =========================
const TEXT = "BananaZZ";

// =========================
// KEYS (EEE3)
// =========================
const K1 = Buffer.from("Informac");
const K2 = Buffer.from("bezopasn");
const K3 = Buffer.from("laborato");

// =========================
// PADDING (Z)
// =========================
function padZ(text) {
  const padLen = BLOCK_SIZE - (text.length % BLOCK_SIZE || BLOCK_SIZE);
  return text + "Z".repeat(padLen);
}

function unpadZ(text) {
  return text.replace(/Z+$/g, "");
}

// =========================
// BLOCK OPS
// =========================
function splitBlocks(buffer) {
  const blocks = [];
  for (let i = 0; i < buffer.length; i += BLOCK_SIZE) {
    blocks.push(buffer.slice(i, i + BLOCK_SIZE));
  }
  return blocks;
}

// =========================
// DES ECB (NO PAD)
// =========================
function desEncrypt(block, key) {
  const c = crypto.createCipheriv("DES-ECB", key, null);
  c.setAutoPadding(false);
  return Buffer.concat([c.update(block), c.final()]);
}

function desDecrypt(block, key) {
  const d = crypto.createDecipheriv("DES-ECB", key, null);
  d.setAutoPadding(false);
  return Buffer.concat([d.update(block), d.final()]);
}

// =========================
// EEE3
// =========================
function EEE3(block) {
  let x = desEncrypt(block, K1);
  x = desEncrypt(x, K2);
  x = desEncrypt(x, K3);
  return x;
}

// =========================
// FULL TEXT
// =========================
function encryptEEE3(data) {
  const blocks = splitBlocks(Buffer.from(data));
  return Buffer.concat(blocks.map(b => EEE3(b)));
}

function decryptEEE3(data) {
  const blocks = splitBlocks(data);
  return Buffer.concat(
    blocks.map(b => {
      let x = desDecrypt(b, K3);
      x = desDecrypt(x, K2);
      x = desDecrypt(x, K1);
      return x;
    })
  );
}

// =========================
// AVALANCHE (EEE3 STEP-BY-STEP)
// =========================
function avalancheStepAnalysis() {
  console.log("\n=== AVALANCHE EEE3 (FULL WORD, EACH DES) ===");

  const baseText = padZ(TEXT);
  const modArr = baseText.split("");

  // меняем 1 символ
  modArr[0] = modArr[0] === "A" ? "B" : "A";
  const modText = modArr.join("");

  console.log("\nORIGINAL:");
  console.log("BASE:", baseText);
  console.log("MOD :", modText);

  const baseBlocks = splitBlocks(Buffer.from(baseText));
  const modBlocks  = splitBlocks(Buffer.from(modText));

  let b1_all = [], m1_all = [];
  let b2_all = [], m2_all = [];
  let b3_all = [], m3_all = [];

  for (let i = 0; i < baseBlocks.length; i++) {

    // DES 1
    const b1 = desEncrypt(baseBlocks[i], K1);
    const m1 = desEncrypt(modBlocks[i], K1);

    b1_all.push(b1);
    m1_all.push(m1);

    // DES 2
    const b2 = desEncrypt(b1, K2);
    const m2 = desEncrypt(m1, K2);

    b2_all.push(b2);
    m2_all.push(m2);

    // DES 3
    const b3 = desEncrypt(b2, K3);
    const m3 = desEncrypt(m2, K3);

    b3_all.push(b3);
    m3_all.push(m3);
  }

  const s1_base = Buffer.concat(b1_all);
  const s1_mod  = Buffer.concat(m1_all);

  const s2_base = Buffer.concat(b2_all);
  const s2_mod  = Buffer.concat(m2_all);

  const s3_base = Buffer.concat(b3_all);
  const s3_mod  = Buffer.concat(m3_all);

  function byteDiff(a, b) {
    let diff = 0;
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) diff++;
    }
    return diff;
  }

  // =========================
  // ВЫВОД
  // =========================

  console.log("\n--- DES 1 (K1) ---");
  console.log("BASE:", s1_base.toString("hex"));
  console.log("MOD :", s1_mod.toString("hex"));
  console.log("diff:", byteDiff(s1_base, s1_mod), "/", s1_base.length);

  console.log("\n--- DES 2 (K2) ---");
  console.log("BASE:", s2_base.toString("hex"));
  console.log("MOD :", s2_mod.toString("hex"));
  console.log("diff:", byteDiff(s2_base, s2_mod), "/", s2_base.length);

  console.log("\n--- DES 3 (K3) ---");
  console.log("BASE:", s3_base.toString("hex"));
  console.log("MOD :", s3_mod.toString("hex"));
  console.log("diff:", byteDiff(s3_base, s3_mod), "/", s3_base.length);
}

// =========================
// SPEED
// =========================
function measure(fn, data, iters = 20) {
  const t0 = Date.now();
  for (let i = 0; i < iters; i++) fn(data);
  return (Date.now() - t0) / iters;
}

// =========================
// MAIN
// =========================
function run() {
  const padded = padZ(TEXT);

  const encrypted = encryptEEE3(padded);
  const decrypted = unpadZ(decryptEEE3(encrypted).toString());

  fs.writeFileSync("encrypted.txt", encrypted.toString("hex"));
  fs.writeFileSync("decrypted.txt", decrypted);

  console.log("Encrypt time:", measure(encryptEEE3, padded), "ms");
  console.log("Decrypt time:", measure(decryptEEE3, encrypted), "ms");

  avalancheStepAnalysis();
}

run();

/*
===========================================================
====================== СТАРЫЙ КОД =========================
===========================================================

// (оставил как есть, если нужно — смотри выше в твоей версии)

*/
