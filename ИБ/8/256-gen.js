const crypto = require('crypto');

function randomBigInt(bits) {
    const bytes = Math.ceil(bits / 8);
    let buf = crypto.randomBytes(bytes);
    let n = BigInt('0x' + buf.toString('hex'));
    n |= (1n << BigInt(bits - 1));
    return n | 1n;
}

function gcd(a, b) {
    while (b !== 0n) {
        [a, b] = [b, a % b];
    }
    return a;
}

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

function isProbablePrime(n, k = 10) {
    if (n < 2n) return false;
    if (n % 2n === 0n) return n === 2n;

    let d = n - 1n, s = 0n;
    while ((d & 1n) === 0n) { d >>= 1n; s++; }

    for (let i = 0; i < k; i++) {
        const a = 2n + (randomBigInt(64) % (n - 3n));
        let x = modPow(a, d, n);
        if (x === 1n || x === n - 1n) continue;

        let ok = false;
        for (let r = 1n; r < s; r++) {
            x = modPow(x, 2n, n);
            if (x === n - 1n) { ok = true; break; }
        }
        if (!ok) return false;
    }
    return true;
}

function genPrime(bits = 256) {
    while (true) {
        let p = randomBigInt(bits);
        if (isProbablePrime(p)) return p;
    }
}

function genE(phi) {
    while (true) {
        let e = randomBigInt(256);
        if (e < phi && gcd(e, phi) === 1n) {
            return e;
        }
    }
}

const p = genPrime(256);
let q;
do { q = genPrime(256); } while (q === p);

const phi = (p - 1n) * (q - 1n);
const e = genE(phi);

console.log("p =", p.toString());
console.log("q =", q.toString());
console.log("e =", e.toString());