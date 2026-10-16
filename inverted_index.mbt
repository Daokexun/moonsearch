///|
/// In-memory inverted index maintaining terms and their document postings.
pub struct InvertedIndex {
  docs : Map[String, Document]
  index : Map[String, Array[Posting]]
  mut total_doc_length : Int
}

///|
/// Creates a new empty InvertedIndex.
pub fn InvertedIndex::new() -> InvertedIndex {
  { docs: Map([]), index: Map([]), total_doc_length: 0 }
}

///|
/// Returns total number of indexed documents.
pub fn InvertedIndex::doc_count(self : InvertedIndex) -> Int {
  self.docs.length()
}

///|
/// Returns average document length across indexed documents.
pub fn InvertedIndex::avg_doc_length(self : InvertedIndex) -> Double {
  let count = self.docs.length()
  if count == 0 {
    0.0
  } else {
    self.total_doc_length.to_double() / count.to_double()
  }
}

///|
/// Indexes a document into the inverted index.
pub fn InvertedIndex::add_document(
  self : InvertedIndex,
  doc : Document
) -> Unit {
  self.docs.set(doc.id, doc)
  self.total_doc_length += doc.length

  let tokens = filter_stopwords(tokenize(doc.text))
  let tf_map : Map[String, Int] = Map([])
  for token in tokens {
    match tf_map.get(token) {
      Some(count) => tf_map.set(token, count + 1)
      None => tf_map.set(token, 1)
    }
  }

  for entry in tf_map {
    let (term, tf) = entry
    let posting = Posting::new(doc.id, tf)
    match self.index.get(term) {
      Some(postings) => postings.push(posting)
      None => self.index.set(term, [posting])
    }
  }
}

///|
/// Retrieves postings list for a given search term.
pub fn InvertedIndex::get_postings(
  self : InvertedIndex,
  term : String
) -> Array[Posting]? {
  self.index.get(term)
}
