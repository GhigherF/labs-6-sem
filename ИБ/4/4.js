import fs from "fs/promises";
import excel from "exceljs";

const RU = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';

function affineEncrypt(text, a, b) {
  return text.split('').map(ch => {
    const i = RU.indexOf(ch);
    return i >= 0 ? RU[(a * i + b) % RU.length] : ch;
  }).join('');
}

function affineDecrypt(text, a, b) {
  const m = RU.length;
  const aInv = Array.from({length: m}, (_, i) => i).find(i => (a * i) % m === 1);
  return text.split('').map(ch => {
    const i = RU.indexOf(ch);
    return i >= 0 ? RU[(aInv * (i - b + m)) % m] : ch;
  }).join('');
}

function vigenereEncrypt(text, keyword) {
  const key = keyword.toUpperCase();
  let ki = 0;
  return text.split('').map(ch => {
    const i = RU.indexOf(ch);
    if (i < 0) return ch;
    const shift = RU.indexOf(key[ki % key.length]);
    ki++;
    return RU[(i + shift) % RU.length];
  }).join('');
}

function vigenereDecrypt(text, keyword) {
  const key = keyword.toUpperCase();
  let ki = 0;
  return text.split('').map(ch => {
    const i = RU.indexOf(ch);
    if (i < 0) return ch;
    const shift = RU.indexOf(key[ki % key.length]);
    ki++
    return RU[(i - shift + RU.length) % RU.length];
  }).join('');
}

function measure(label, fn) {
  const t = performance.now();
  const result = fn();
  console.log(`${label}: ${(performance.now() - t).toFixed(3)} мс`);
  return result;
}

const workbook = new excel.Workbook();
const sheet1 = workbook.addWorksheet();

let text = (await fs.readFile('./text.txt')).toString().toUpperCase();
let lettersMap = [];
for (const letter of text) {
  lettersMap[letter] = (lettersMap[letter] || 0) + 1;
}
const russianLetters = Object.entries(lettersMap)
  .filter(([letter]) => /^[\u0400-\u04FF]$/.test(letter))
  .sort((a, b) => new Intl.Collator('ru').compare(a[0], b[0]));

const AFFINE_A = 7;
const AFFINE_B = 10;
const VIGENERE_KEY = 'Дмитроченко';

console.log (`Количество символов: ${text.length}`)
const caesarText    = measure('Аффинное шифрование',     () => affineEncrypt(text, AFFINE_A, AFFINE_B));
const caesarDecText = measure('Аффинное расшифрование',  () => affineDecrypt(caesarText, AFFINE_A, AFFINE_B));
const vigenereText    = measure('Виженер шифрование',    () => vigenereEncrypt(text, VIGENERE_KEY));
const vigenereDecText = measure('Виженер расшифрование', () => vigenereDecrypt(vigenereText, VIGENERE_KEY));

await fs.writeFile('./caesar.txt', caesarText);
await fs.writeFile('./caesar_dec.txt', caesarDecText);
await fs.writeFile('./vigenere.txt', vigenereText);
await fs.writeFile('./vigenere_dec.txt', vigenereDecText);

function countLetters(text) {
  const map = [];
  for (const ch of text) map[ch] = (map[ch] || 0) + 1;
  return map;
}

const caesarMap = countLetters(caesarText);
const vigenereMap = countLetters(vigenereText);

sheet1.addRow(['Буква', 'Кол-во', '', '', 'Цезарь (буква)', 'Цезарь (кол-во)', '', '', 'Виженер (буква)', 'Виженер (кол-во)']);

russianLetters.forEach(([letter, count], idx) => {
  const row = sheet1.getRow(idx + 2);
  const caesarLetter = affineEncrypt(letter, AFFINE_A, AFFINE_B);
  const vigenereLetter = vigenereEncrypt(letter, VIGENERE_KEY);
  row.getCell(1).value = letter;
  row.getCell(2).value = count;
  row.getCell(5).value = caesarLetter;
  row.getCell(6).value = caesarMap[caesarLetter] || 0;
  row.getCell(9).value = vigenereLetter;
  row.getCell(10).value = vigenereMap[vigenereLetter] || 0;
  row.commit();
});
