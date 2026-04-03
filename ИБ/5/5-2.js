const ExcelJS = require("exceljs");

let MESSAGE = `«Хочу обратить внимание всех. Встречался со многими милиционерами, которые погибли. С людьми-демонстрантами, которые погибли. И все задают вопрос…»
У меня есть два заместителя, четыре из которых уже месяц лежат в кабинете министров и которых назначить невозможно. Не знаю почему».
«Она находится везде. Она находится в Киеве. Сегодня она улетела в Германию. Она работает по всему миру. Вообще она находится там, где я».
В Одесской области город, 50 километров, недалеко. Знаете, не в километрах расстояние измеряется. Два часа. Пятьдесят километров нужно ехать два часа.`;

MESSAGE = MESSAGE.toUpperCase();

// --- Настройки ключей ---
const horizontalKey = "КИРИЛЛ";   // Имя
const verticalKey = "ДМИТРОЧЕНКО"; // Фамилия

// --- Фильтрация текста (только буквы и пробелы) ---
function filterSymbols(text) {
  return text.split("").filter(c => c.match(/[А-Я ]/)).join("");
}

// --- Сдвиговое шифрование символов ---
function encrypt(text, shift = 3) {
  return text.split("").map(c => String.fromCharCode(c.charCodeAt(0) + shift)).join("");
}

function decrypt(text, shift = 3) {
  return text.split("").map(c => String.fromCharCode(c.charCodeAt(0) - shift)).join("");
}

// --- Частотный анализ ---
function frequency(text) {
  const freq = {};
  for (let c of text) {
    if (c.match(/[А-Я ]/)) freq[c] = (freq[c] || 0) + 1;
  }
  return freq;
}

// --- Создание ключей с индексами (для таблицы) ---
function createIndexedKeyAlpha(key, repeat) {
  const letters = key.split("");
  const sorted = [...letters].sort((a,b)=>a.localeCompare(b));
  const result = [];
  for (let r = 0; r < repeat; r++) {
    for (let l of letters) {
      const alphaIndex = sorted.indexOf(l) + 1 + r*letters.length;
      result.push({c: l, index: alphaIndex});
    }
  }
  return result;
}

// --- Построение таблицы по ключам ---
function buildTable(text, hKey, vKey) {
  const rows = vKey.length;
  const cols = hKey.length;
  const table = [];
  let counter = 0;
  for (let r = 0; r < rows; r++) {
    const row = [];
    for (let c = 0; c < cols; c++) {
      row.push(counter < text.length ? text[counter++] : "");
    }
    table.push(row);
  }
  return table;
}

// --- Запись таблицы Excel ---
async function writeExcelTable(table, hKey, vKey, filename) {
  const wb = new ExcelJS.Workbook();
  const ws = wb.addWorksheet("Table");

  const columns = [{header:"", key:"vkey", width:5}];
  for (let hk of hKey) {
    columns.push({header:`${hk.c}(${hk.index})`, key:hk.c+hk.index+Math.random(), width:3});
  }
  ws.columns = columns;

  for (let r=0;r<table.length;r++) {
    const rowData = {vkey:`${vKey[r].c}(${vKey[r].index})`};
    for (let c=0;c<table[r].length;c++) {
      rowData[columns[c+1].key] = table[r][c];
    }
    ws.addRow(rowData);
  }

  await wb.xlsx.writeFile(filename);
}

// --- Запись частот символов ---
async function writeFrequencyTable(freq, filename) {
  const wb = new ExcelJS.Workbook();
  const ws = wb.addWorksheet("Frequency");
  ws.columns = [
    {header:"Символ", key:"char", width:5},
    {header:"Частота", key:"count", width:10}
  ];
  Object.keys(freq).sort().forEach(ch => {
    ws.addRow({char:ch, count:freq[ch]});
  });
  await wb.xlsx.writeFile(filename);
}

// --- Основной запуск ---
(async()=>{
  const filtered = filterSymbols(MESSAGE);

  // --- Ключи с индексами ---
  const hKeyIndexed = createIndexedKeyAlpha(horizontalKey,6);
  const vKeyIndexed = createIndexedKeyAlpha(verticalKey,2);

  // --- Таблица исходного текста ---
  const tableOriginal = buildTable(filtered, hKeyIndexed, vKeyIndexed.length);
  await writeExcelTable(tableOriginal, hKeyIndexed, vKeyIndexed, "table_initial.xlsx");

  // --- Шифрование ---
  console.time("Encryption");
  const encryptedText = encrypt(filtered, 3);
  console.timeEnd("Encryption");

  // --- Расшифрование ---
  console.time("Decryption");
  const decryptedText = decrypt(encryptedText, 3);
  console.timeEnd("Decryption");

  // --- Частоты ---
  const freqOriginal = frequency(filtered);
  const freqEncrypted = frequency(encryptedText);

  await writeFrequencyTable(freqOriginal, "frequency_original.xlsx");
  await writeFrequencyTable(freqEncrypted, "frequency_encrypted.xlsx");

  console.log("Всего символов (буквы и пробелы):", filtered.length);
})();
