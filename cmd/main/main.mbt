///|
/// Demonstration entry point for moonsearch engine.
fn main {
  println("=== MoonSearch Demo ===")

  let index = @lib.InvertedIndex::new()

  let doc1 = @lib.Document::new(
    "doc1",
    "MoonBit is an AI-friendly language built for WebAssembly and cloud.",
  )
  let doc2 = @lib.Document::new(
    "doc2",
    "WebAssembly provides high performance in modern browser environments.",
  )
  let doc3 = @lib.Document::new(
    "doc3",
    "Full-text search engines use inverted indices and BM25 relevance scoring.",
  )

  index.add_document(doc1)
  index.add_document(doc2)
  index.add_document(doc3)

  println("Indexed documents: \{index.doc_count()}")
  println("Average document length: \{index.avg_doc_length()}")

  let query_term = "webassembly"
  match index.get_postings(query_term) {
    Some(postings) => {
      println("Search query for: '\{query_term}'")
      let idf = @lib.calculate_idf(index.doc_count(), postings.length())
      let params = @lib.BM25Params::default()
      for p in postings {
        let score = @lib.score_term(
          p.term_frequency,
          50,
          index.avg_doc_length(),
          idf,
          params,
        )
        println("  -> Matched Doc: \{p.doc_id}, TF: \{p.term_frequency}, BM25 Score: \{score}")
      }
    }
    None => println("No documents found for '\{query_term}'")
  }

  println("=== Demo Finished Successfully ===")
}
