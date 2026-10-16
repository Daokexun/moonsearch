test "tokenize basic sentence" {
  let tokens = @moonsearch.tokenize("Hello, World! 123")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
  assert_eq(tokens[2], "123")
}

test "tokenize multiple whitespace and symbols" {
  let tokens = @moonsearch.tokenize("  MoonBit  --- is   FAST!!!  ")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], "moonbit")
  assert_eq(tokens[1], "is")
  assert_eq(tokens[2], "fast")
}

test "tokenize empty text" {
  let tokens = @moonsearch.tokenize("")
  assert_eq(tokens.length(), 0)
}
