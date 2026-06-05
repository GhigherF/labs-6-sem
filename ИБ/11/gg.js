import crypto from 'node:crypto';
import { performance } from 'node:perf_hooks';

/**
 * 1. Замер быстродействия на твоем ФИО
 */
function measureDefaultMessage(message) {
  console.log(`=== 1. Быстродействие SHA-256 ===`);

  const start = performance.now();
  const hash = crypto.createHash('sha256').update(message).digest('hex');
  const end = performance.now();

  console.log(`Данные: "${message}"`);
  console.log(`Хеш: ${hash}`);
  console.log(`Время: ${(end - start).toFixed(6)} мс\n`);
  console.log('='.repeat(60) + '\n');
}

/**
 * 2. Поиск коллизий (Парадокс дня рождения)
 */
function analyzeBirthdayParadox(bits) {
  const seenHashes = new Map();
  const hexChars = bits / 4; // Количество символов hex, которые должны совпасть
  let attempts = 0;

  const startTime = performance.now();

  while (true) {
    attempts++;
    // Генерируем случайную строку
    const data = crypto.randomBytes(16).toString('hex');
    const fullHash = crypto.createHash('sha256').update(data).digest('hex');

    // Берем начало хеша (префикс) заданной длины
    const shortHash = fullHash.substring(0, hexChars);

    if (seenHashes.has(shortHash)) {
      const endTime = performance.now();
      const prev = seenHashes.get(shortHash);

      console.log(`[Сложность: ${bits} бит]`);
      console.log(`Попыток: ${attempts} | Время: ${(endTime - startTime).toFixed(2)} мс`);

      // Наглядное сравнение
      console.log(`Сообщение 1: ${prev.msg}`);
      console.log(`Хеш 1: [${shortHash}]${prev.full.substring(hexChars)}`);

      console.log(`Сообщение 2: ${data}`);
      console.log(`Хеш 2: [${shortHash}]${fullHash.substring(hexChars)}`);

      console.log(`Результат: Первые ${hexChars} симв. совпали!`);
      console.log('-'.repeat(40));
      break;
    }

    // Сохраняем сообщение и его полный хеш
    seenHashes.set(shortHash, { msg: data, full: fullHash });
  }
}

// --- ЗАПУСК ---

// Замер для отчета
measureDefaultMessage("Дмитроченко Кирилл Денисович".repeat(1750));
console.log("Дмитроченко Кирилл Денисович".repeat(1750).length)
console.log(`=== 2. Анализ коллизий (Парадокс дня рождения) ===`);
console.log(`Сравниваем полные хеши для поиска совпадений по префиксу:\n`);

// Запускаем для разной сложности
//[48].forEach(bitSize => {
//analyzeBirthdayParadox(bitSize);
//});
