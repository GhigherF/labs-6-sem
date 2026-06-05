const { performance } = require('perf_hooks');
const asciichart = require('asciichart');

function powerMod(a, x, n) {
  let res = 1n;
  a = a % n;
  while (x > 0n) {
    if (x % 2n === 1n) res = (res * a) % n;
    a = (a * a) % n;
    x = x / 2n;
  }
  return res;
}

// 1. Исходные данные
const a = 27n; // Число из диапазона [5, 35]
const n1024 = (2n ** 1025n) - 295n; // Число n (1024 бита)
const n2048 = (2n ** 2049n) - 2881n; // Число n (2048 бит)

// Генерация x (от 10^3 до 10^100) — 10 логарифмически распределенных значений
const xValues = [];
for (let i = 3; i <= 100; i += 10) {
  xValues.push(BigInt("1" + "0".repeat(i)));
}

console.log(`Тестирование для a = ${a}\n`);

function runTest(nValue, label) {
  const times = [];
  console.log(`--- Результаты для n (${label} бит) ---`);
  console.log(`| x (порядок) | Время (мс) |`);
  console.log(`|-------------|------------|`);

  xValues.forEach(x => {
    const start = performance.now();
    powerMod(a, x, nValue);
    const end = performance.now();
    const duration = (end - start).toFixed(4);

    times.push(parseFloat(duration));
    console.log(`| 10^${x.toString().length - 1}${" ".repeat(7 - (x.toString().length - 1).toString().length)}| ${duration} |`);
  });

  console.log(`\nГрафик зависимости времени (мс) от роста порядка x:`);
  console.log(asciichart.plot(times, { height: 10 }));
  console.log("\n");
}

// 2. Запуск тестов
runTest(n1024, "1024");
runTest(n2048, "2048");
