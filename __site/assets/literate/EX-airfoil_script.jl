# This file was generated, do not modify it.

using MLJ, PrettyPrinting, DataFrames, Statistics, CSV
using PyPlot, HTTP

MLJ.color_off() # hide

req = HTTP.get("https://raw.githubusercontent.com/rupakc/UCI-Data-Analysis/master/Airfoil%20Dataset/airfoil_self_noise.dat");

df = CSV.read(req.body; header=[
                  "Frequency","Attack_Angle","Chord+Length",
                  "Free_Velocity","Suction_Side","Scaled_Sound"
              ]
       );
df[1:5, :] |> pretty

schema(df)

y, X = unpack(df, ==(:Scaled_Sound), col -> true);

X = transform(fit!(machine(Standardizer(), X)), X);

train, test = partition(eachindex(y), 0.7, shuffle=true);

for model in models(matching(X, y))
       print("Model Name: " , model.name , " , Package: " , model.package_name , "\n")
end

coerce!(X, :Frequency=>Continuous)

for model in models(matching(X, y))
       print("Model Name: " , model.name , " , Package: " , model.package_name , "\n")
end

dcr = @load DecisionTreeRegressor pkg=DecisionTree

dcrm = machine(dcr, X, y)

fit!(dcrm, rows=train, force=true)
pred_dcrm = MLJ.predict(dcrm, rows=test);

rms(pred_dcrm, y[test])

rfr = @load RandomForestRegressor pkg=DecisionTree

rfr_m = machine(rfr, X, y);

fit!(rfr_m, rows=train);

pred_rfr = MLJ.predict(rfr_m, rows=test);
rms(pred_rfr, y[test])

r_maxD = range(rfr, :n_trees, lower=9, upper=15)
r_samF = range(rfr, :sampling_fraction, lower=0.6, upper=0.8)
r = [r_maxD, r_samF];

tuning = Grid(resolution=7)
resampling = CV(nfolds=6)

tm = TunedModel(model=rfr, tuning=tuning,
                resampling=resampling, ranges=r, measure=rms)

rfr_tm = machine(tm, X, y);

fit!(rfr_tm, rows=train);

pred_rfr_tm = MLJ.predict(rfr_tm, rows=test);
rms(pred_rfr_tm, y[test])

fitted_params(rfr_tm).best_model

r = report(rfr_tm)
res = r.plotting

md = res.parameter_values[:,1]
mcw = res.parameter_values[:,2]

figure(figsize=(8,6))
tricontourf(md, mcw, res.measurements)

xlabel("Number of trees", fontsize=14)
ylabel("Sampling fraction", fontsize=14)
xticks(9:1:15, fontsize=12)
yticks(fontsize=12)
plt.savefig(joinpath(@OUTPUT, "airfoil_heatmap.svg")) # hide

PyPlot.close_figs() # hide

