const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

const ROTORS = {
  II:   "AJDKSIRUXBLHWTMCQGZNPYFVOE",
  III:  "BDFHJLCPRTXVZNYEIWGAKMUSQO",
  V:    "VZBRGITYUPSDNHLXAWMJQOFECK"
};

const REFLECTOR_C = "FVPJIAOYEDRZXWGCTKUQSBNMHL";

const letterToIndex = (l) => ALPHABET.indexOf(l);
const indexToLetter = (i) => ALPHABET[i];

const rings = [1,2,2].map(x => x - 1);

function rotorForward(letter, rotor, pos, ring) {
  const idx = (letterToIndex(letter) + pos - ring + 26) % 26;
  const wired = rotor[idx];
  const outIdx = (letterToIndex(wired) - pos + ring + 26) % 26;
  return indexToLetter(outIdx);
}

function rotorBackward(letter, rotor, pos, ring) {
  const idx = (letterToIndex(letter) + pos - ring + 26) % 26;
  const wiredIndex = rotor.indexOf(ALPHABET[idx]);
  const outIdx = (wiredIndex - pos + ring + 26) % 26;
  return indexToLetter(outIdx);
}

function reflect(letter) {
  return REFLECTOR_C[letterToIndex(letter)];
}

function encryptLetter(letter, rotorConfig, positions) {
  const log = [];

  log.push({ step: "IN", letter });

  let l = letter;

  l = rotorForward(l, ROTORS[rotorConfig[2]], positions[2], rings[2]); log.push({ step: `Ri ${rotorConfig[2]}`, letter: l });
  l = rotorForward(l, ROTORS[rotorConfig[1]], positions[1], rings[1]); log.push({ step: `Mi ${rotorConfig[1]}`, letter: l });
  l = rotorForward(l, ROTORS[rotorConfig[0]], positions[0], rings[0]); log.push({ step: `Li ${rotorConfig[0]}`, letter: l });

  l = reflect(l); log.push({ step: "REFL C", letter: l });

  l = rotorBackward(l, ROTORS[rotorConfig[0]], positions[0], rings[0]); log.push({ step: `Li ${rotorConfig[0]} back`, letter: l });
  l = rotorBackward(l, ROTORS[rotorConfig[1]], positions[1], rings[1]); log.push({ step: `Mi ${rotorConfig[1]} back`, letter: l });
  l = rotorBackward(l, ROTORS[rotorConfig[2]], positions[2], rings[2]); log.push({ step: `Ri ${rotorConfig[2]} back`, letter: l });

  log.push({ step: "OUT", letter: l });

  return log;
}

const rotorConfig = ["II","III","V"];

let positions = ["N","O","Z"].map(letterToIndex);

const word = "A";

for (const ch of word) {
  console.log(`\n=== Letter: ${ch} ===`);
  console.log(`Positions: ${positions.map(indexToLetter).join(" ")}`);

  const result = encryptLetter(ch, rotorConfig, positions);

  result.forEach(r => console.log(`${r.step}: ${r.letter}`));

  positions[2] = (positions[2] + 1) % 26;
}
