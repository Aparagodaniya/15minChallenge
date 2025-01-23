# 15minChallenge

## 用 14 个因子预测 237 个加密货币的 15 分钟收益率。
1. 数据请联系管理员获得。
2. 使用 alhpa.jl 查看因子、预测目标、237 个加密货币、统计指标。
3. 可以预测 rtn 的数值，也可以预测 rtn 的 rank。
4. rtn 的数值用 $R^2$ 评价好坏。
   $R^2 \equiv 1 - \frac{\rm 残差}{方差}$，
   可以参考 ic, ir, MIC, y ~ $\hat{y}$ 等相关性统计。
6. rank 的数值用 kendalltau 评价好坏。
   $\tau \equiv \frac{4\\#disorder}{n(n-1)}$，
   可以参考 spearman 等涉及顺序的统计指标。
7. 根据 rtn 或 rank 的预测值将 237 个加密币分成 10 组，计算 yhat 最高和最低的两组分别做多和做空的实际收益率期望。
