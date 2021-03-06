# This file was generated, do not modify it. # hide
using MLJ, RDatasets, PrettyPrinting
MLJ.color_off() # hide
import Distributions
const D = Distributions

@load LinearRegressor pkg=MLJLinearModels
@load RidgeRegressor pkg=MLJLinearModels
@load LassoRegressor pkg=MLJLinearModels

hitters = dataset("ISLR", "Hitters")
@show size(hitters)
names(hitters) |> pprint