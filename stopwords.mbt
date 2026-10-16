///|
/// Checks if a lowercase token is a common English stopword.
pub fn is_stopword(word : String) -> Bool {
  match word {
    "a" | "an" | "the" | "and" | "or" | "but" | "if" | "then" | "else" => true
    "is" | "are" | "was" | "were" | "be" | "been" | "being" => true
    "in" | "on" | "at" | "to" | "for" | "of" | "with" | "by" | "from" => true
    "it" | "its" | "this" | "that" | "these" | "those" => true
    _ => false
  }
}

///|
/// Filters out stopwords from a token array.
pub fn filter_stopwords(tokens : Array[String]) -> Array[String] {
  let result : Array[String] = []
  for token in tokens {
    if is_stopword(token) == false {
      result.push(token)
    }
  }
  result
}
