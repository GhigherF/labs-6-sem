const ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

const ROTORS = {
  II:  "AJDKSIRUXBLHWTMCQGZNPYFVOE",
  III: "BDFHJLCPRTXVZNYEIWGAKMUSQO",
  V:   "VZBRGITYUPSDNHLXAWMJQOFECK"
};

const REFLECTOR = "FVPJIAOYEDRZXWGCTKUQSBNMHL";

const toIdx = c => ABC.indexOf(c);
const toChar = i => ABC[i];

function forward(c, rotor, pos) {
  const step1 = (toIdx(c) + pos) % 26;
  const wired = rotor[step1];
  const step2 = (toIdx(wired) - pos + 26) % 26;

  return toChar(step2);
}

function backward(c, rotor, pos) {
  const step1 = (toIdx(c) + pos) % 26;
  const idx = rotor.indexOf(ABC[step1]);
  const step2 = (idx - pos + 26) % 26;

  return toChar(step2);
}

function processLetter(letter, rotors, pos) {
  let log = [];
  let c = letter;

  log.push(`IN  : ${c}`);

  c = forward(c, rotors[2], pos[2]); log.push(`R→  : ${c}`);
  c = forward(c, rotors[1], pos[1]); log.push(`M→  : ${c}`);
  c = forward(c, rotors[0], pos[0]); log.push(`L→  : ${c}`);

  c = REFLECTOR[toIdx(c)];
  log.push(`REF : ${c}`);

  c = backward(c, rotors[0], pos[0]); log.push(`L←  : ${c}`);
  c = backward(c, rotors[1], pos[1]); log.push(`M←  : ${c}`);
  c = backward(c, rotors[2], pos[2]); log.push(`R←  : ${c}`);

  log.push(`OUT : ${c}`);
  return { result: c, log };
}

function enigma(text, rotorNames, startPos) {
  const rotors = rotorNames.map(r => ROTORS[r]);
  let pos = startPos.map(toIdx);

  let result = "";

  for (let ch of text) {
    if (!ABC.includes(ch)) continue;

    const { result: out, log } = processLetter(ch, rotors, pos);

    console.log("\n=== LETTER:", ch, "===");
    console.log("POS:", pos.map(toChar).join(" "));
    log.forEach(l => console.log(l));

    result += out;

    pos[2] = (pos[2] + 1) % 26;
  }

  return result;
}

const rotors = ["II", "III", "V"];
const positions = ["A", "A", "A"];

const encrypted = enigma("A", rotors, positions);
console.log("Encrypted:", encrypted);

const decrypted = enigma(encrypted, rotors, positions);
console.log("Decrypted:", decrypted);






