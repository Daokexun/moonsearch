///|
/// 内部辅助函数：将字符串按 Unicode 字符 (`Char`) 拆分为数组
/// 确保中文、Emoji 等多字节 UTF-16 字符按完整码点计算编辑距离
fn string_to_chars(s : String) -> Array[Char] {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  chars
}

///|
/// 内部辅助函数：两个整数取较小值
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// 内部辅助函数：三个整数取最小值
fn min3_int(a : Int, b : Int, c : Int) -> Int {
  min_int(a, min_int(b, c))
}

///|
/// 内部辅助函数：整数绝对值
fn abs_int(x : Int) -> Int {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
/// 计算两个字符串 `a` 与 `b` 之间的经典 Levenshtein 编辑距离
/// - 允许的操作：插入 (Insertion)、删除 (Deletion)、替换 (Substitution)，单次代价均为 1
/// - 优化策略：
///   1. 相等字符串 $O(1)$ 快速返回
///   2. 公共前后缀裁剪，缩小动态规划矩阵规模
///   3. 滚动一维数组动态规划，空间复杂度优化至 $O(\min(|a|, |b|))$
pub fn levenshtein_distance(a : String, b : String) -> Int {
  if a == b {
    return 0
  }
  let chars_a = string_to_chars(a)
  let chars_b = string_to_chars(b)
  let len_a = chars_a.length()
  let len_b = chars_b.length()

  if len_a == 0 {
    return len_b
  }
  if len_b == 0 {
    return len_a
  }

  // 裁剪公共前缀
  let mut start = 0
  while start < len_a && start < len_b && chars_a[start] == chars_b[start] {
    start = start + 1
  }

  // 裁剪公共后缀
  let mut end_a = len_a
  let mut end_b = len_b
  while end_a > start &&
        end_b > start &&
        chars_a[end_a - 1] == chars_b[end_b - 1] {
    end_a = end_a - 1
    end_b = end_b - 1
  }

  let m = end_a - start
  let n = end_b - start
  if m == 0 {
    return n
  }
  if n == 0 {
    return m
  }

  // 保持内层循环在较短序列上进行，使空间复杂度为 O(min(m, n))
  if m < n {
    return levenshtein_dp(chars_b, start, n, chars_a, start, m)
  }
  levenshtein_dp(chars_a, start, m, chars_b, start, n)
}

///|
/// 内部辅助函数：滚动数组 Levenshtein DP 核心实现
fn levenshtein_dp(
  long_chars : Array[Char],
  long_offset : Int,
  m : Int,
  short_chars : Array[Char],
  short_offset : Int,
  n : Int,
) -> Int {
  let dp : Array[Int] = Array::make(n + 1, 0)
  for j in 0..<=n {
    dp[j] = j
  }

  for i in 1..<=m {
    let mut prev_diag = dp[0]
    dp[0] = i
    let ca = long_chars[long_offset + i - 1]
    for j in 1..<=n {
      let temp = dp[j]
      let cost = if ca == short_chars[short_offset + j - 1] { 0 } else { 1 }
      let deletion = dp[j] + 1
      let insertion = dp[j - 1] + 1
      let substitution = prev_diag + cost
      dp[j] = min3_int(deletion, insertion, substitution)
      prev_diag = temp
    }
  }
  dp[n]
}

///|
/// 容错模糊匹配判断：判断 `query` 与 `target` 的编辑距离是否在 `max_distance` 以内
/// - 包含多级剪枝优化：
///   1. `max_distance < 0` 直接返回 `false`
///   2. `max_distance == 0` 退化为精确相等判断
///   3. 长度差下界剪枝：若 `||query| - |target|| > max_distance` 直接返回 `false`
///   4. DP 行最小值早停剪枝 (Early Termination)：若当前行最小编辑距离已超过 `max_distance`，提前终止并返回 `false`
pub fn is_fuzzy_match(
  query : String,
  target : String,
  max_distance : Int,
) -> Bool {
  if max_distance < 0 {
    return false
  }
  if query == target {
    return true
  }
  if max_distance == 0 {
    return false
  }

  let chars_q = string_to_chars(query)
  let chars_t = string_to_chars(target)
  let len_q = chars_q.length()
  let len_t = chars_t.length()

  // 长度差下界剪枝
  if abs_int(len_q - len_t) > max_distance {
    return false
  }

  // 裁剪公共前缀与公共后缀
  let mut start = 0
  while start < len_q && start < len_t && chars_q[start] == chars_t[start] {
    start = start + 1
  }
  let mut end_q = len_q
  let mut end_t = len_t
  while end_q > start &&
        end_t > start &&
        chars_q[end_q - 1] == chars_t[end_t - 1] {
    end_q = end_q - 1
    end_t = end_t - 1
  }

  let m = end_q - start
  let n = end_t - start
  if m == 0 {
    return n <= max_distance
  }
  if n == 0 {
    return m <= max_distance
  }

  // 带行最小值早停的滚动数组 DP
  let dp : Array[Int] = Array::make(n + 1, 0)
  for j in 0..<=n {
    dp[j] = j
  }

  for i in 1..<=m {
    let mut prev_diag = dp[0]
    dp[0] = i
    let mut row_min = dp[0]
    let cq = chars_q[start + i - 1]
    for j in 1..<=n {
      let temp = dp[j]
      let cost = if cq == chars_t[start + j - 1] { 0 } else { 1 }
      let deletion = dp[j] + 1
      let insertion = dp[j - 1] + 1
      let substitution = prev_diag + cost
      let cell = min3_int(deletion, insertion, substitution)
      dp[j] = cell
      if cell < row_min {
        row_min = cell
      }
      prev_diag = temp
    }
    // 早停剪枝：当前行所有状态的最小编辑距离已超出阈值
    if row_min > max_distance {
      return false
    }
  }

  dp[n] <= max_distance
}
