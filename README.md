# 15minChallenge

## 用 16 个因子预测 197 个加密货币的 15 分钟收益率。
1. 数据请联系管理员获得。
2. 使用 alhpa.jl 查看数据、因子、预测目标、197 个加密货币
3. 可以预测 rtn 的数值，也可以预测 rtn 的 rank。
4. rtn 的数值用 $R^2$ 和尾部期望评价好坏。
   $R^2 \equiv 1 - \frac{\rm 残差}{方差}$，
   可以参考 ic, ir, MIC, y ~ $\hat{y}$ 等相关性统计。
5. rank 的数值用 kendalltau 评价好坏。
   $\tau \equiv \frac{4\\#disorder}{n(n-1)}$，
   可以参考 spearman 等涉及顺序的统计指标。
6. 根据 rtn 或 rank 的预测值将 197 个加密币分成 10 组，计算每组的实际收益率之和。
 
