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
df.Date  = df.close_time .|> Date;

# %%
println("label: $(label)")
for (i, x) ∈ alpha |> enumerate
    println("alpha $(i): $(x)")
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
function pearson(x, y) 
    z = cor(x, y)
    if z === NaN
        return missing
    else    
        return z
    end
end
function kT(x, y)
    z = corkendall(x, y)
    if z === NaN
        return missing
    else
        return z
    end
end
function spearman(x, y)
    z = corspearman(x, y)
    if z === NaN
        return missing
    else
        return z
    end
end
println("A Fake yhat = mean(y)")
yhat = fill(mean(y), length(y))
df.yhat = yhat
groupInfo = combine(
    groupby(df, "group_id"),
    [:yhat, Symbol(label)] => pearson => :ic,
    [:yhat, Symbol(label)] => r2_score => :r2,
)
ic = groupInfo.ic |> skipmissing |> mean 
@show ic |> digit3
ir = ic / (groupInfo.ic |> skipmissing |> std)
@show ir  |> digit3
r2 = groupInfo.r2 |> skipmissing |> mean
@show r2 |> digit3
println("A Fake yhat = rank(y)")
yhat = ordinalrank(y)
df.yhat = yhat
groupInfo = combine(
    groupby(df, "group_id"),
    [:yhat, Symbol(label)] => kT => :tau,
    [:yhat, Symbol(label)] => spearman => :spearman,
)
tau = groupInfo.tau |> skipmissing |> mean
spr = groupInfo.spearman |> skipmissing |> mean
@show tau |> digit3
@show spr |> digit3
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
posRtnMean = rtn[!, :posRtn] |> mean
@show posRtnMean |> digit3
negRtnMean = rtn[!, :negRtn] |> mean
@show negRtnMean |> digit3;

# %%
