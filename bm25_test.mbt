test "bm25 idf calculation positive" {
  let idf = @moonsearch.calculate_idf(100, 5)
  assert_true(idf > 0.0)
}

test "bm25 score monotonic with term frequency" {
  let params = @moonsearch.BM25Params::default()
  let idf = 2.5
  let score1 = @moonsearch.score_term(1, 50, 50.0, idf, params)
  let score2 = @moonsearch.score_term(3, 50, 50.0, idf, params)
  assert_true(score2 > score1)
}
