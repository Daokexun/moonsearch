///|
/// 内部辅助函数：按 Unicode 字符码点比较两个 Char
fn compare_char(c1 : Char, c2 : Char) -> Int {
  let u1 = c1.to_int()
  let u2 = c2.to_int()
  if u1 < u2 {
    -1
  } else if u1 > u2 {
    1
  } else {
    0
  }
}

///|
/// 字符串比较函数：按 Unicode 码点顺序严格比较两个字符串
/// - 返回值：a < b 返回 -1，a > b 返回 1，相等返回 0
pub fn compare_string(a : String, b : String) -> Int {
  let chars_a = a.to_array()
  let chars_b = b.to_array()
  let len_a = chars_a.length()
  let len_b = chars_b.length()
  let min_len = if len_a < len_b { len_a } else { len_b }
  for i in 0..<min_len {
    let cmp = compare_char(chars_a[i], chars_b[i])
    if cmp != 0 {
      return cmp
    }
  }
  if len_a < len_b {
    -1
  } else if len_a > len_b {
    1
  } else {
    0
  }
}

///|
/// 对字符串数组按 Unicode 字典序升序原地排序（稳定插入排序）
pub fn sort_strings(arr : Array[String]) -> Unit {
  let len = arr.length()
  for i in 1..<len {
    let key = arr[i]
    let mut j = i - 1
    while j >= 0 && compare_string(arr[j], key) > 0 {
      arr[j + 1] = arr[j]
      j = j - 1
    }
    arr[j + 1] = key
  }
}

///|
/// 前缀字典树节点 (Trie Node)
/// - `children`: 子节点映射表，按 Unicode 字符 `Char` 索引，支持中英文及多语言词项
/// - `is_end`: 标记当前节点是否为某个完整词项的结尾
/// - `word`: 当 `is_end` 为 `true` 时直接缓存完整词项，避免 DFS 阶段重复拼接字符串
pub(all) struct TrieNode {
  children : Map[Char, TrieNode]
  mut is_end : Bool
  mut word : String?
} derive(Debug, Eq)

///|
/// 创建空的字典树节点
pub fn TrieNode::new() -> TrieNode {
  TrieNode::{ children: Map([]), is_end: false, word: None }
}

///|
/// 前缀字典树 (Prefix Trie)
/// 用于 `moonsearch` 全文检索引擎的前缀查询与搜索自动补全 (Auto-completion)
pub(all) struct Trie {
  root : TrieNode
  mut size : Int
} derive(Debug, Eq)

///|
/// 创建空的前缀字典树
pub fn Trie::new() -> Trie {
  Trie::{ root: TrieNode::new(), size: 0 }
}

///|
/// 从词项数组批量构建前缀字典树
pub fn Trie::from_array(words : Array[String]) -> Trie {
  let trie = Trie::new()
  for word in words {
    trie.insert(word)
  }
  trie
}

///|
/// 返回字典树中已存储的不同词项数量
pub fn Trie::length(self : Trie) -> Int {
  self.size
}

///|
/// 判断字典树是否为空
pub fn Trie::is_empty(self : Trie) -> Bool {
  self.size == 0
}

///|
/// 向字典树中插入一个词项
/// - 忽略空字符串 `""`
/// - 重复插入相同词项具有幂等性，不会重复计数
pub fn Trie::insert(self : Trie, word : String) -> Unit {
  if word == "" {
    return
  }
  let mut curr = self.root
  for ch in word {
    match curr.children.get(ch) {
      Some(next_node) => curr = next_node
      None => {
        let new_node = TrieNode::new()
        curr.children[ch] = new_node
        curr = new_node
      }
    }
  }
  if !curr.is_end {
    curr.is_end = true
    curr.word = Some(word)
    self.size = self.size + 1
  }
}

///|
/// 精确查找某个词项是否存在于字典树中
pub fn Trie::contains(self : Trie, word : String) -> Bool {
  if word == "" {
    return false
  }
  match self.find_node(word) {
    Some(node) => node.is_end
    None => false
  }
}

///|
/// 判断是否存在以 `prefix` 开头的前缀路径
pub fn Trie::starts_with(self : Trie, prefix : String) -> Bool {
  if prefix == "" {
    return self.size > 0
  }
  self.find_node(prefix) is Some(_)
}

///|
/// 内部辅助函数：沿着给定字符串路径查找对应节点
fn Trie::find_node(self : Trie, path : String) -> TrieNode? {
  let mut curr = self.root
  for ch in path {
    match curr.children.get(ch) {
      Some(next_node) => curr = next_node
      None => return None
    }
  }
  Some(curr)
}

///|
/// 内部辅助函数：深度优先遍历收集子树中的所有完整词项
fn collect_words(node : TrieNode, results : Array[String]) -> Unit {
  if node.is_end {
    match node.word {
      Some(w) => results.push(w)
      None => ()
    }
  }
  for _, child in node.children {
    collect_words(child, results)
  }
}

///|
/// 前缀查找：返回所有以 `prefix` 开头的词项（按字典序排序），用于搜索建议（Auto-completion）
/// - 当 `prefix` 不匹配任何节点时返回空数组 `[]`
/// - 当 `prefix` 为空字符串 `""` 时返回字典树中的所有词项
pub fn Trie::find_by_prefix(self : Trie, prefix : String) -> Array[String] {
  let start_node = match self.find_node(prefix) {
    Some(node) => node
    None => return []
  }
  let results : Array[String] = []
  collect_words(start_node, results)
  sort_strings(results)
  results
}

///|
/// 搜索自动补全（支持限制返回条数 `limit`，按字典序返回前 K 条建议）
pub fn Trie::suggest(
  self : Trie,
  prefix : String,
  limit~ : Int = 10,
) -> Array[String] {
  if limit <= 0 {
    return []
  }
  let matches = self.find_by_prefix(prefix)
  if matches.length() <= limit {
    return matches
  }
  let limited : Array[String] = []
  for i in 0..<limit {
    limited.push(matches[i])
  }
  limited
}
