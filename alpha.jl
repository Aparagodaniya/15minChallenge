# %%
using Dates
using DataFrames
using Parquet

# %%
df = "alpha.parquet" |> read_parquet |> DataFrame
df.open_time = unix2datetime.(df.open_time / 1000000)
df.close_time = unix2datetime.(df.close_time / 1000000)
for col ∈ df |> eachcol
    replace!(col, NaN => missing)
end
df |> dropmissing!
label = "future_return_15m"
alpha = [
    col for col ∈ names(df)
    if col ∉ ["symbol", "group_id", "open_time", "close_time", label]
]
rename!(df, "close_time" => "Timestamp", "symbol" => "Code")
df.Date  = df.Timestamp .|> Date

# %%
println("label: $(label)")
for (i, x) ∈ alpha |> enumerate
    println("alpha$(i): $(x)")
end

# %%
