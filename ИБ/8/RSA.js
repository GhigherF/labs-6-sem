const p = 68083162428906146532553232381355939466530287158335712361313727988744673235939n;
const q = 60492265754905551734973151926452053007380830712608358044445667003897452421321n;
const e = 85997932872981737598304354206810014981522108836922997360689521075531005586229n;

const n = p * q;
const phi = (p - 1n) * (q - 1n);

// расширенный Евклид
function egcd(a, b) {
    if (b === 0n) return [a, 1n, 0n];
    const [g, x1, y1] = egcd(b, a % b);
    return [g, y1, x1 - (a / b) * y1];
}

function modInv(a, m) {
    const [g, x] = egcd(a, m);
    if (g !== 1n) throw new Error("Нет обратного элемента");
    return (x % m + m) % m;
}

const d = modInv(e, phi);

// быстрое возведение в степень
function modPow(base, exp, mod) {
    let res = 1n;
    base %= mod;
    while (exp > 0n) {
        if (exp & 1n) res = (res * base) % mod;
        base = (base * base) % mod;
        exp >>= 1n;
    }
    return res;
}





const iterations = 50000;
const message = 12345678901234567890n;

// ШИФРОВАНИЕ
let startEnc = process.hrtime.bigint();

for (let i = 0; i < iterations; i++) {
    modPow(message, e, n);
}

let endEnc = process.hrtime.bigint();

// РАСШИФРОВАНИЕ
const cipher = modPow(message, e, n);

let startDec = process.hrtime.bigint();

for (let i = 0; i < iterations; i++) {
    modPow(cipher, d, n);
}

let endDec = process.hrtime.bigint();

// результаты
const encTime = Number(endEnc - startEnc) / 1e6;
const decTime = Number(endDec - startDec) / 1e6;

console.log("=== PERFORMANCE ===");
console.log("Encrypt total ms:", encTime);
console.log("Decrypt total ms:", decTime);
console.log("Encrypt per op ms:", encTime / iterations);
console.log("Decrypt per op ms:", decTime / iterations);








