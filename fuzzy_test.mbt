///|
test "levenshtein_distance classic cases" {
  // 相同字符串与空字符串边界
  assert_eq(levenshtein_distance("", ""), 0)
  assert_eq(levenshtein_distance("moonbit", ""), 7)
  assert_eq(levenshtein_distance("", "moonbit"), 7)
  assert_eq(levenshtein_distance("moonsearch", "moonsearch"), 0)

  // 经典编辑距离测试集
  assert_eq(levenshtein_distance("kitten", "sitting"), 3)
  assert_eq(levenshtein_distance("flaw", "lawn"), 2)
  assert_eq(levenshtein_distance("saturday", "sunday"), 3)
  assert_eq(levenshtein_distance("intention", "execution"), 5)

  // 单次编辑（插入、删除、替换）
  assert_eq(levenshtein_distance("search", "serch"), 1) // 删除 'a'
  assert_eq(levenshtein_distance("search", "seach"), 1) // 删除 'r'
  assert_eq(levenshtein_distance("search", "searche"), 1) // 插入 'e'
  assert_eq(levenshtein_distance("search", "seorch"), 1) // 替换 'a' -> 'o'
}

///|
test "levenshtein_distance unicode and chinese" {
  assert_eq(levenshtein_distance("全文检索", "全文检索"), 0)
  assert_eq(levenshtein_distance("全文检索", "全文搜索"), 1)
  assert_eq(levenshtein_distance("倒排索引", "倒排索引表"), 1)
  assert_eq(levenshtein_distance("搜索引擎", "检索引擎"), 1)
}

///|
test "is_fuzzy_match threshold and pruning" {
  // 阈值边界测试
  assert_false(is_fuzzy_match("moon", "moon", -1))
  assert_true(is_fuzzy_match("moon", "moon", 0))
  assert_false(is_fuzzy_match("moon", "moons", 0))
  assert_true(is_fuzzy_match("moon", "moons", 1))

  // 拼写纠错容错匹配
  assert_true(is_fuzzy_match("serch", "search", 1))
  assert_true(is_fuzzy_match("kittn", "kitten", 1))
  assert_false(is_fuzzy_match("kitten", "sitting", 2))
  assert_true(is_fuzzy_match("kitten", "sitting", 3))

  // 长度差剪枝与早停剪枝测试
  assert_false(is_fuzzy_match("a", "abcdef", 2))
  assert_false(is_fuzzy_match("abcdef", "uvwxyz", 2))

  // 中文容错匹配
  assert_true(is_fuzzy_match("全文搜索", "全文检索", 1))
  assert_false(is_fuzzy_match("全文搜索", "倒排索引", 2))
}
