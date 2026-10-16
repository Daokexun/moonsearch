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

test "stopword filtering" {
  let tokens = @moonsearch.tokenize("This is a fast search engine with MoonBit")
  let filtered = @moonsearch.filter_stopwords(tokens)
  assert_eq(filtered.length(), 4)
  assert_eq(filtered[0], "fast")
  assert_eq(filtered[1], "search")
  assert_eq(filtered[2], "engine")
  assert_eq(filtered[3], "moonbit")
}
