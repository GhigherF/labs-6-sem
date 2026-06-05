function NOD2(a, b) {
    a = Math.abs(a);
    b = Math.abs(b);

    while (b !== 0) {
        let temp = b;
        b = a % b;
        a = temp;
    }

    return a;
}

function NOD3(a, b, c) {
    return NOD2(NOD2(a, b), c);
}


function findPrimesInRange(start, end) {
    if (end < 2) return [];

    const prost = new Array(end + 1).fill(true);
    prost[0] = prost[1] = false;

    for (let i = 2; i * i <= end; i++) {
        if (prost[i]) {
            for (let j = i * i; j <= end; j += i) {
                prost[j] = false;
            }
        }
    }

    const primes = [];
    for (let i = Math.max(2, start); i <= end; i++) {
        if (prost[i]) {
            primes.push(i);
        }
    }

    return primes;
}


//console.log("НОД(521, 553) =", NOD2(521, 553));

//console.log("НОД(5252, 6767, 4242) =", NOD3(5252, 6767, 4242));

//console.log("Простые числа от 521 до 553:");
console.log(findPrimesInRange(2**255,2**256));
//console.log("Простые числа от 3 до 553:");
//console.log(findPrimesInRange(3, 553));