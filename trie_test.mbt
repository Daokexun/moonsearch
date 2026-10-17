///|
test "trie basic insert and contains" {
  let trie = Trie::new()
  assert_true(trie.is_empty())
  assert_eq(trie.length(), 0)

  trie.insert("moon")
  trie.insert("moonbit")
  trie.insert("moonsearch")
  trie.insert("moon") // 重复插入应当幂等
  trie.insert("") // 空字符串应被忽略

  assert_false(trie.is_empty())
  assert_eq(trie.length(), 3)
  assert_true(trie.contains("moon"))
  assert_true(trie.contains("moonbit"))
  assert_true(trie.contains("moonsearch"))
  assert_false(trie.contains("moo"))
  assert_false(trie.contains("moonlight"))
  assert_false(trie.contains(""))
}

///|
test "trie find_by_prefix for auto-completion" {
  let trie = Trie::from_array([
    "search",
    "engine",
    "moon",
    "moonbit",
    "moonsearch",
    "mooncake",
    "memory",
  ])

  // "moon" 前缀匹配应按字典序返回 4 个候选词
  assert_eq(trie.find_by_prefix("moon"), [
    "moon",
    "moonbit",
    "mooncake",
    "moonsearch",
  ])

  // "m" 前缀匹配包含 "memory" 和 "moon*" 系列
  assert_eq(trie.find_by_prefix("m"), [
    "memory",
    "moon",
    "moonbit",
    "mooncake",
    "moonsearch",
  ])

  // 唯一匹配与完整词项自身匹配
  assert_eq(trie.find_by_prefix("sea"), ["search"])
  assert_eq(trie.find_by_prefix("moonsearch"), ["moonsearch"])

  // 无匹配前缀
  assert_eq(trie.find_by_prefix("rust"), [])
  assert_eq(trie.find_by_prefix("moonsearch_extra"), [])
}

///|
test "trie unicode and chinese support" {
  let trie = Trie::from_array([
    "全文检索",
    "全文搜索引擎",
    "全部",
    "倒排索引",
    "前缀树",
    "前缀匹配",
  ])

  assert_eq(trie.length(), 6)
  assert_true(trie.starts_with("全文"))
  assert_true(trie.starts_with("前缀"))
  assert_false(trie.starts_with("分词"))

  assert_eq(trie.find_by_prefix("全文"), ["全文搜索引擎", "全文检索"])
  assert_eq(trie.find_by_prefix("前缀"), ["前缀匹配", "前缀树"])
}

///|
test "trie suggest with limit and empty prefix" {
  let trie = Trie::from_array(["apple", "app", "application", "apply", "apt"])

  // Top-3 自动补全建议
  assert_eq(trie.suggest("app", limit=3), ["app", "apple", "application"])
  assert_eq(trie.suggest("app", limit=0), [])

  // 空前缀返回全部词项（字典序）
  assert_eq(trie.find_by_prefix(""), [
    "app",
    "apple",
    "application",
    "apply",
    "apt",
  ])
}
