///|
/// Demonstration entry point for moonsearch engine.
fn main {
  println("==================================================")
  println("           MoonSearch Full-Text Engine            ")
  println("==================================================")

  // 1. 倒排索引与 BM25 检索演示
  println("\n--- [1] Inverted Index & BM25 Relevance Scoring ---")
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

  // 2. 前缀字典树与自动补全演示
  println("\n--- [2] Prefix Trie & Auto-completion ---")
  let trie = @lib.Trie::from_array([
    "moon",
    "moonbit",
    "moonsearch",
    "mooncake",
    "memory",
    "module",
    "webassembly",
  ])
  println("Total words indexed in Trie: \{trie.length()}")
  let suggestions = trie.suggest("moon", limit=3)
  println("Auto-completion suggestions for prefix 'moon' (limit 3):")
  for s in suggestions {
    println("  - \{s}")
  }

  // 3. 模糊匹配与拼写纠错演示
  println("\n--- [3] Levenshtein Distance & Fuzzy Match ---")
  let typo_word = "serch"
  let correct_target = "search"
  let dist = @lib.levenshtein_distance(typo_word, correct_target)
  let matched = @lib.is_fuzzy_match(typo_word, correct_target, 1)
  println("Distance between '\{typo_word}' and '\{correct_target}': \{dist}")
  println("Is fuzzy match within threshold 1: \{matched}")

  println("\n==================================================")
  println("=== All Engines & Demos Completed Successfully ===")
  println("==================================================")
}
