# %%
using Dates
using DataFrames
using Parquet
using StatsBase
using StatsModels
using Metrics

# %%
df = "alpha.parquet" |> read_parquet |> DataFrame
@show df |> size
df.open_time = unix2datetime.(df.open_time / 1000000)
df.close_time = unix2datetime.(df.close_time / 1000000)
select!(df, Not(["big_buy_ratio_o", "small_sell_ratio_o"]))
for col ∈ df |> eachcol
    replace!(col, NaN => missing)
end
df |> dropmissing!
label = "future_return_15m"
alpha = [
    col for col ∈ names(df)
    if col ∉ ["symbol", "group_id", "open_time", "close_time", label]
]
rename!(df, "symbol" => "Code")
df.Date  = df.close_time .|> Date

# %%
println("label: $(label)")
for (i, x) ∈ alpha |> enumerate
    println("alpha$(i): $(x)")
end

# %%
println("ALL Codes")
codes = df.Code |> unique |> sort
@show codes |> length
for (i, code) ∈ codes |> enumerate
    println("Code $(i): $(code)")
end

# %%
x = df[!, alpha] |> Matrix;
y = df[!, label] |> Vector;
@show x |> size
@show y |> size

# %%
digit3 = x -> round(x, digits = 3)
println("A Fake yhat = mean(y)")
yhat = fill(mean(y), length(y))
@show ic = cor(yhat, y) |> digit3
@show ir = cor(yhat, y) / std(y) |> digit3
@show r2 = r2_score(yhat, y) |> digit3
println("A Fake yhat = rank(y)")
yhat = ordinalrank(y)
@show tau = corkendall(yhat, y) |> digit3
@show spearman = corspearman(yhat, y) |> digit3
df.yhat = yhat
function posRtn(_y, y)
    best = partialsortperm(_y, 1 : length(_y) ÷ 10; rev = true)
    y[best] |> sum
end
function negRtn(_y, y)
    best = partialsortperm(_y, 1 : length(_y) ÷ 10)
    - y[best] |> sum
end
rtn = combine(
    groupby(df, "group_id"),
    [:yhat, Symbol(label)] => posRtn => :posRtn,
    [:yhat, Symbol(label)] => negRtn => :negRtn,
)
@show rtn[!, :posRtn] |> mean |> digit3;
@show rtn[!, :negRtn] |> mean |> digit3;

# %%
