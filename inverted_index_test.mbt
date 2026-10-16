test "inverted index basic addition and retrieval" {
  let index = @moonsearch.InvertedIndex::new()
  let doc1 = @moonsearch.Document::new("1", "MoonBit programming language")
  let doc2 = @moonsearch.Document::new("2", "Rust and MoonBit comparison")

  index.add_document(doc1)
  index.add_document(doc2)

  assert_eq(index.doc_count(), 2)

  let postings = index.get_postings("moonbit")
  match postings {
    Some(list) => {
      assert_eq(list.length(), 2)
      assert_eq(list[0].doc_id, "1")
      assert_eq(list[1].doc_id, "2")
    }
    None => abort("expected postings for 'moonbit'")
  }

  let prog_postings = index.get_postings("programming")
  match prog_postings {
    Some(list) => {
      assert_eq(list.length(), 1)
      assert_eq(list[0].doc_id, "1")
    }
    None => abort("expected postings for 'programming'")
  }
}
