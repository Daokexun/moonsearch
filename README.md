# moonsearch

A lightweight, zero-dependency, in-memory full-text search engine written natively in **MoonBit**, optimized for **WebAssembly**, edge runtimes, and client-side applications.

Inspired by [MiniSearch](https://github.com/lucaong/minisearch) and [rank_bm25](https://github.com/dorianbrown/rank_bm25).

---

## Features

- **Pure MoonBit**: Zero external runtime dependencies, compiles cleanly to WebAssembly (`wasm`/`wasm-gc`) and native binaries.
- **Inverted Index**: High-performance inverted index with term frequency (TF) and document frequency (DF) tracking.
- **BM25 Relevance Scoring**: Standard Okapi BM25 algorithm with configurable document length normalization and term saturation.
- **Prefix Matching (Trie)**: Built-in Radix/Trie structure for instant auto-complete and search-as-you-type suggestions.
- **Fuzzy Search**: Levenshtein distance matching for typo tolerance.
- **Field Boosting**: Multi-field search with custom weights (e.g., title vs body).

---

## Architecture Overview

```
moonsearch/
├── moon.mod             # Module manifest
├── moon.pkg             # Package configuration
├── types.mbt            # Core types (Document, SearchResult, QueryOptions)
├── tokenizer.mbt        # Text splitting, normalization, and stopword filters
├── inverted_index.mbt   # Posting lists and document frequency maps
├── bm25.mbt             # Okapi BM25 scoring engine
├── trie.mbt             # Trie data structure for prefix search
├── fuzzy.mbt            # Levenshtein distance calculation
├── engine.mbt           # Top-level SearchEngine orchestrator
└── cmd/
    └── main/            # Runnable CLI demonstration
```

---

## Quickstart

```moonbit
import "username/moonsearch" as search

fn main {
  let engine = search::SearchEngine::new()
  engine.add_document("doc1", "MoonBit is an AI-friendly programming language.")
  engine.add_document("doc2", "WebAssembly runs efficiently in browsers and edge.")
  
  let results = engine.search("MoonBit language")
  for r in results {
    println("Found document: \{r.id} with score: \{r.score}")
  }
}
```

---

## License

Apache-2.0 License.
