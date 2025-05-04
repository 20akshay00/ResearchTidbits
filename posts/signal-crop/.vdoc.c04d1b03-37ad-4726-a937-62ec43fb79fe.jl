#
#
#
#
#
#
#
#
#
#
#
#| echo: false
begin
    using Pkg
    Pkg.activate("../../")
    Pkg.instantiate()
    using JLD2, Plots, StatsBase
end
#
#
#
begin
    data = load("signal.jld2")["images"]
    plot(heatmap(data[1], title="Image #1"), heatmap(data[2], title="Image #2"), size=(1000, 300))
end
#
#
#
#
#
#
#
#
#
#
#
#
#
function cube(anchor, window)
    return [
        rmin:rmax for (rmin, rmax) in
        zip(anchor .- window, anchor .+ window)
    ]
end
#
#
#
#
measure_extent(data, anchor, window) = std(data[cube(anchor, window)...])
#
#
#
#
# extract (hyper-)cubical ranges for cropping; f - measure of extent
function crop_extents(data; scale=5, max_window=200, f=measure_extent)
    anchor = Tuple(argmax(data)) # replace with robust peak finding algorithm 	
    extent = argmax([f(data, anchor, window) for window in 1:max_window])

    return cube(anchor, extent * scale)
end
#
#
#
#
#
let
    gaussian1D(x, A, x0, sig) = A * exp(-(x - x0)^2 / (2 * sig^2))
    x = -50:0.1:50
    y = gaussian1D.(x, 1, 20, 1)
    yerr = 0.5 * rand(length(x))

    anchor, anchorerr = argmax(y), argmax(y .+ yerr)
    windows = 1:170
    rng = [measure_extent(y, anchor, window) for window in windows]
    rngerr = [measure_extent(y .+ yerr, anchor, window) for window in windows]

    plot(windows, rng, lab="Clean signal", lw=2, c=1)
    plot!(windows, rngerr, lab="Noisy signal", lw=2, c=2)
    vline!([argmax(rng)], c=1, lab="", ls=:dash, alpha=0.75)
    vline!([argmax(rngerr)], c=2, lab="", ls=:dash, alpha=0.75)

    plot!(legend=:bottomright, xlabel="Independant variable", ylabel="Measure of signal spread")
end
#
#
#
#
#
#| echo: false
let
    gaussian1D(x, A, x0, sig) = A * exp(-(x - x0)^2 / (2 * sig^2))
    x = -50:0.1:50
    y = gaussian1D.(x, 1, 35, 1) .+ 0.5 * rand(length(x))
    rng = crop_extents(y; max_window=10)
    p1 = plot(x, y, lw=1, lab="", title="Raw data")
    p2 = plot(x[rng...], y[rng...], lab="", title="Cropped data")
    plot(p1, p2, size=(1000, 300), legend=:topleft)
end
#
#
#
#| echo: false
let
    d = data[1]
    rng = crop_extents(d)

    p1 = heatmap(d, title="Raw image")
    p2 = heatmap(rng[1], rng[2], d[rng...], title="Cropped image")
    display(plot(p1, p2, size=(1000, 300)))

    d = data[2]
    rng = crop_extents(d)

    p1 = heatmap(d, title="Raw image")
    p2 = heatmap(rng[1], rng[2], d[rng...], title="Cropped image")
    display(plot(p1, p2, size=(1000, 300)))
end
#
#
#
#
#
#
#
#
#
#
#
#
#
#
