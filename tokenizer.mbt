///|
/// Helper to check if a character is a letter or number.
pub fn is_alphanumeric(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') ||
  (c >= 'A' && c <= 'Z') ||
  (c >= '0' && c <= '9') ||
  (c >= '\u{4e00}' && c <= '\u{9fa5}')
}

///|
/// Converts an uppercase ASCII character to lowercase.
pub fn to_lower_char(c : Char) -> Char {
  if c >= 'A' && c <= 'Z' {
    Int::unsafe_to_char(c.to_int() + 32)
  } else {
    c
  }
}

///|
/// Tokenizes text into an array of lowercase alphanumeric tokens.
pub fn tokenize(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut current = StringBuilder()
  for c in text {
    if is_alphanumeric(c) {
      current.write_char(to_lower_char(c))
    } else if current.is_empty() == false {
      tokens.push(current.to_string())
      current = StringBuilder()
    }
  }
  if current.is_empty() == false {
    tokens.push(current.to_string())
  }
  tokens
}
