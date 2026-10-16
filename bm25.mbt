///|
/// Parameters for Okapi BM25 scoring algorithm.
pub struct BM25Params {
  k1 : Double
  b : Double
} derive(Eq, Debug)

///|
/// Default parameters: k1 = 1.2, b = 0.75.
pub fn BM25Params::default() -> BM25Params {
  { k1: 1.2, b: 0.75 }
}

///|
/// Computes Inverse Document Frequency (IDF) using Robertson-Spärck Jones formula.
pub fn calculate_idf(total_docs : Int, doc_frequency : Int) -> Double {
  if total_docs == 0 || doc_frequency == 0 {
    return 0.0
  }
  let n = doc_frequency.to_double()
  let total = total_docs.to_double()
  let numerator = total - n + 0.5
  let denominator = n + 0.5
  let val = numerator / denominator
  if val <= 0.0 {
    0.0
  } else {
    let x = (val - 1.0) / (val + 1.0)
    let x2 = x * x
    let mut sum = 0.0
    let mut term = x
    for i in [1, 3, 5, 7, 9] {
      sum += term / i.to_double()
      term = term * x2
    }
    2.0 * sum
  }
}

///|
/// Computes BM25 score contribution for a single term in a document.
pub fn score_term(
  tf : Int,
  doc_len : Int,
  avg_doc_len : Double,
  idf : Double,
  params : BM25Params
) -> Double {
  if tf <= 0 || idf <= 0.0 {
    return 0.0
  }
  let tf_d = tf.to_double()
  let norm_len = if avg_doc_len > 0.0 {
    doc_len.to_double() / avg_doc_len
  } else {
    1.0
  }
  let denom = tf_d + params.k1 * (1.0 - params.b + params.b * norm_len)
  if denom <= 0.0 {
    0.0
  } else {
    idf * (tf_d * (params.k1 + 1.0)) / denom
  }
}
