///|
/// Represents a searchable document stored in the engine.
pub struct Document {
  id : String
  text : String
  length : Int
} derive(Eq, Debug)

///|
/// Creates a new Document with calculated length.
pub fn Document::new(id : String, text : String) -> Document {
  { id, text, length: text.length() }
}

///|
/// Posting entry in the inverted index tracking term occurrence in a document.
pub struct Posting {
  doc_id : String
  term_frequency : Int
} derive(Eq, Debug)

///|
pub fn Posting::new(doc_id : String, term_frequency : Int) -> Posting {
  { doc_id, term_frequency }
}

///|
/// Search options for querying the engine.
pub struct SearchOptions {
  prefix : Bool
  fuzzy_distance : Int
  limit : Int
} derive(Eq, Debug)

///|
/// Default search options.
pub fn SearchOptions::default() -> SearchOptions {
  { prefix: false, fuzzy_distance: 0, limit: 10 }
}

///|
/// Result item returned from a search query.
pub struct SearchResult {
  id : String
  score : Double
  match_count : Int
} derive(Debug)

///|
pub fn SearchResult::new(
  id : String,
  score : Double,
  match_count : Int
) -> SearchResult {
  { id, score, match_count }
}
