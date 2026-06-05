const crypto = require('crypto');
const readline = require('readline');

// Функция для красивого оформления консоли
function printHeader(title) {
  console.log("\n" + "=".repeat(50));
  console.log(` ${title} `.padStart(25 + Math.floor(title.length / 2)).padEnd(50, "="));
  console.log("=".repeat(50));
}

// Настройка ввода из консоли
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Введите сообщение для подписания: ', (messageText) => {
  const message = Buffer.from(messageText, 'utf-8');

  // 1. ГЕНЕРАЦИЯ КЛЮЧЕЙ
  printHeader("1. Генерация ключей RSA (2048 бит)");
  console.log("[...] Генерируем пару ключей, пожалуйста, подождите...");

  // Используем high-resolution таймер для точных замеров (в наносекундах)
  let start = process.hrtime.bigint();

  // Генерируем ключи асинхронно-подобным методом в памяти
  const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 4096, // Стандартная безопасная длина
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' }
  });

  let end = process.hrtime.bigint();
  const keyGenTime = Number(end - start) / 1e9; // Переводим в секунды

  console.log("[OK] Ключи успешно сгенерированы!");
  console.log(` Время генерации ключей: ${keyGenTime.toFixed(4)} сек.`);

  // 2. ПОДПИСАНИЕ СООБЩЕНИЯ
  printHeader("2. Генерация ЭЦП (Подписание)");
  console.log("[...] Вычисляем хэш SHA-256 и накладываем подпись...");

  start = process.hrtime.bigint();

  // Используем современную схему RSA-PSS и хэш SHA-256
  const signature = crypto.sign(
    'sha256',
    message,
    {
      key: privateKey,
      padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
      saltLength: crypto.constants.RSA_PSS_SALTLEN_MAX
    }
  );

  end = process.hrtime.bigint();
  const signTime = Number(end - start) / 1e9;

  console.log("[OK] Сообщение успешно подписано!");
  console.log(`Размер подписи: ${signature.length} байт (${signature.length * 8} бит)`);
  console.log(`Время генерации подписи: ${signTime.toFixed(6)} сек.`);
  console.log(`Signature (HEX): ${signature.toString('hex').slice(0, 60)}...`);

  // 3. ВЕРИФИКАЦИЯ (ПРОВЕРКА) ПОДПИСИ
  printHeader("3. Верификация ЭЦП (Проверка)");
  console.log("[...] Проверяем подпись с использованием открытого ключа...");

  start = process.hrtime.bigint();

  const isValid = crypto.verify(
    'sha256',
    message,
    {
      key: publicKey,
      padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
      saltLength: crypto.constants.RSA_PSS_SALTLEN_MAX
    },
    signature
  );

  end = process.hrtime.bigint();
  const verifyTime = Number(end - start) / 1e9;

  if (isValid) {
    console.log("[ВЕРИФИКАЦИЯ УСПЕШНА]  Подпись верна! Целостность данных подтверждена.");
  } else {
    console.log("[ВНИМАНИЕ]  Подпись НЕВЕРНА!");
  }
  console.log(`Время верификации подписи: ${verifyTime.toFixed(6)} сек.`);

  // 4. ИМИТАЦИЯ АТАКИ
  printHeader("4. Тест на компрометацию (Атака)");
  console.log("Попробуем изменить один символ в исходном сообщении...");
  const fakedMessage = Buffer.from(messageText + "!", 'utf-8');

  const isFakeValid = crypto.verify(
    'sha256',
    fakedMessage,
    {
      key: publicKey,
      padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
      saltLength: crypto.constants.RSA_PSS_SALTLEN_MAX
    },
    signature
  );

  if (!isFakeValid) {
    console.log("[OK] Система успешно обнаружила подделку! Подпись отвергнута.");
  } else {
    console.log("[КРИТИЧЕСКАЯ ОШИБКА] Система приняла измененный текст!");
  }

  // СВОДНЫЙ АНАЛИЗ СКОРОСТИ
  printHeader("ИТОГОВЫЙ АНАЛИЗ СКОРОСТИ");
  console.log(`1. Генерация пары ключей:  ${keyGenTime.toFixed(4)} сек.`);
  console.log(`2. Создание подписи:       ${signTime.toFixed(6)} сек.`);
  console.log(`3. Проверка подписи:       ${verifyTime.toFixed(6)} сек.`);
  console.log("-".repeat(50));

  const ratio = verifyTime > 0 ? (signTime / verifyTime) : 0;
  console.log(`Результат: Верификация прошла в ${ratio.toFixed(1)} раз(а) БЫСТРЕЕ, чем подписание.`);
  console.log("=" * 50);

  rl.close();
});
