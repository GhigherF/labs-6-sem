const crypto = require('node:crypto');
const { performance } = require('node:perf_hooks');

const fullName = "Дмитроченко Кирилл Денисович".repeat(2);
const keySize = 2048;

console.log(`=== RSA (OpenSSL Engine) ===`);

// 1. Генерация ключей
const t0 = performance.now();
const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
  modulusLength: keySize,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
});
const t1 = performance.now();

// 2. Шифрование
const inputBuffer = Buffer.from(fullName, 'utf8');
const t2 = performance.now();
const encrypted = crypto.publicEncrypt(
  { key: publicKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING },
  inputBuffer
);
const t3 = performance.now();

// 3. Расшифрование
const t4 = performance.now();
const decrypted = crypto.privateDecrypt(
  { key: privateKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING },
  inputBuffer.length > 0 ? encrypted : Buffer.alloc(0)
);
const t5 = performance.now();

// Вывод метрик
const encSize = encrypted.length;
const originalSize = inputBuffer.length;

console.log(`Текст: ${fullName}`);
console.log(fullName.length)
console.log(`Размер оригинала: ${originalSize} байт`);
console.log(`Размер криптотекста: ${encSize} байт`);
console.log(`Коэффициент увеличения: ${(encSize / originalSize).toFixed(2)}x`);
console.log(`---`);
console.log(`Время генерации ключей: ${(t1 - t0).toFixed(4)} мс`);
console.log(`Время зашифрования: ${(t3 - t2).toFixed(4)} мс`);
console.log(`Время расшифрования: ${(t5 - t4).toFixed(4)} мс`);
console.log(`Результат расшифрования: ${decrypted.toString('utf8')}`);
