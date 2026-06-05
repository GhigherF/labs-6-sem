const assert = require("assert");

function assertEqual(actual, expected, message = "") {
  assert.strictEqual(actual, expected);
  console.log(`[PASS] ${message}`);
}

function assertIncludes(actual, expected, message = "") {
  assert.ok(actual.includes(expected));
  console.log(`[PASS]  ${message}`);
}

function assertTrue(condition, message = "") {
  assert.ok(condition);
  console.log(`[PASS] ${message}`);
}

module.exports = {
  assertEqual,
  assertIncludes,
  assertTrue
};
