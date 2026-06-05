const { performance } = require('perf_hooks');

const key = [76, 111, 85, 54, 211];

// --- KSA ---
function KSA(key) {
    const S = Array.from({ length: 256 }, (_, i) => i);

    let j = 0;
    for (let i = 0; i < 256; i++) {
        j = (j + S[i] + key[i % key.length]) % 256;
        [S[i], S[j]] = [S[j], S[i]];
    }

    return S;
}

// --- PRGA ---
function PRGA(S, length) {
    let i = 0, j = 0;
    const keystream = [];

    for (let k = 0; k < length; k++) {
        i = (i + 1) % 256;
        j = (j + S[i]) % 256;

        [S[i], S[j]] = [S[j], S[i]];

        const t = (S[i] + S[j]) % 256;
        keystream.push(S[t]);
    }

    return keystream;
}

// --- RC4 ---
function rc4(data, key) {
    const S = KSA(key);
    const keystream = PRGA(S, data.length);
    return data.map((b, i) => b ^ keystream[i]);
}

// --- данные ---
const text = "Hello RC4!";
const data = Array.from(Buffer.from(text));

// --- один раз покажем S ---
const S_debug = KSA(key);
console.log("S после KSA (первые 20):", S_debug.slice(0, 20));

// --- шифрование ---
const t1 = performance.now();
const encrypted = rc4(data, key);
const t2 = performance.now();

// --- расшифрование ---
const t3 = performance.now();
const decrypted = rc4(encrypted, key);
const t4 = performance.now();

// --- вывод ---
console.log("Зашифровано:", encrypted);
console.log("Расшифровано:", Buffer.from(decrypted).toString());

console.log("Время шифрования:", (t2 - t1).toFixed(4), "ms");
console.log("Время расшифрования:", (t4 - t3).toFixed(4), "ms");
