const crypto = require("crypto");

function generateSuperIncreasing(n, bits) {
    let seq = [];
    let sum = 0n;

    for (let i = 0; i < n; i++) {
        let next;
        if (i === n - 1) {
            next = (1n << BigInt(bits)) + sum + 1n;
        } else {
            next = sum + BigInt(Math.floor(Math.random() * 10) + 1);
        }
        seq.push(next);
        sum += next;
    }

    return seq;
}

function gcd(a, b) {
    while (b !== 0n) {
        [a, b] = [b, a % b];
    }
    return a;
}

function modInverse(a, m) {
    let m0 = m, x0 = 0n, x1 = 1n;

    while (a > 1n) {
        let q = a / m;
        [a, m] = [m, a % m];
        [x0, x1] = [x1 - q * x0, x0];
    }

    if (x1 < 0n) x1 += m0;
    return x1;
}

function randomBigInt(max) {
    const bytes = Math.ceil(max.toString(2).length / 8);

    let rnd;
    do {
        rnd = BigInt("0x" + crypto.randomBytes(bytes).toString("hex"));
    } while (rnd >= max || rnd < 2n);

    return rnd;
}

function generateKeys(z, bits = 100) {
    const w = generateSuperIncreasing(z, bits);
    const sum = w.reduce((a, b) => a + b, 0n);

    const q = sum + 1000n;

    let r;
    do {
        r = randomBigInt(q - 1n);
    } while (gcd(r, q) !== 1n);

    const b = w.map(x => (x * r) % q);

    return { w, q, r, b };
}

function stringToBits(str, mode) {
    let bytes;

    if (mode === "base64") {
        const base64 = Buffer.from(str).toString("base64");
        bytes = Buffer.from(base64);
    } else {
        bytes = Buffer.from(str, "ascii");
    }

    let bits = [];

    for (let byte of bytes) {
        for (let i = 7; i >= 0; i--) {
            bits.push((byte >> i) & 1);
        }
    }

    return bits;
}

function bitsToString(bits, mode) {
    let bytes = [];

    for (let i = 0; i < bits.length; i += 8) {
        let byte = 0;
        for (let j = 0; j < 8; j++) {
            byte = (byte << 1) | (bits[i + j] || 0);
        }
        bytes.push(byte);
    }

    const buf = Buffer.from(bytes);

    if (mode === "base64") {
        return Buffer.from(buf.toString(), "base64").toString();
    }

    return buf.toString("ascii");
}

function encrypt(bits, b, z) {
    let result = [];

    for (let i = 0; i < bits.length; i += z) {
        let chunk = bits.slice(i, i + z);

        while (chunk.length < z) chunk.push(0);

        let sum = 0n;

        for (let j = 0; j < z; j++) {
            if (chunk[j]) sum += b[j];
        }

        result.push(sum);
    }

    return result;
}

function decrypt(cipher, w, q, r, z) {
    const rInv = modInverse(r, q);

    let bits = [];

    for (let c of cipher) {
        let s = (c * rInv) % q;

        let chunk = Array(z).fill(0);

        for (let i = z - 1; i >= 0; i--) {
            if (w[i] <= s) {
                chunk[i] = 1;
                s -= w[i];
            }
        }

        bits.push(...chunk);
    }

    return bits;
}

function measure(fn) {
    const start = process.hrtime.bigint();
    const result = fn();
    const end = process.hrtime.bigint();

    return {
        result,
        time: Number(end - start) / 1e6
    };
}

function printArray(name, arr) {
    console.log(name + ":");
    console.log(arr.map(x => x.toString()));
    console.log();
}

function runTest(text, mode, z) {
    console.log("====================================");
    console.log("MODE:", mode.toUpperCase(), "| z =", z);
    console.log("TEXT:", text);
    console.log("====================================");

    const { w, q, r, b } = generateKeys(z);

    printArray("Superincreasing sequence (w)", w);

    console.log("q =", q.toString());
    console.log("r =", r.toString());
    console.log();

    printArray("Public key (b)", b);

    const bits = stringToBits(text, mode);
    printArray("Bits", bits);

    const enc = measure(() => encrypt(bits, b, z));
    printArray("Cipher", enc.result);

    const dec = measure(() => decrypt(enc.result, w, q, r, z));
    printArray("Decrypted bits", dec.result);

    const decoded = bitsToString(dec.result.slice(0, bits.length), mode);

    console.log("Decoded text:", decoded);
    console.log();

    console.log("Encryption time (ms):", enc.time);
    console.log("Decryption time (ms):", dec.time);
    console.log("SUCCESS:", decoded === text);
    console.log("\n\n");
}

const text = "Dmitrochenko Kirill Denisovich";

runTest(text, "ascii", 800);
runTest(text, "base64", 4);
