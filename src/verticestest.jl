# VERTICES TEST
# Plotting scenarios and its convex hull
p= scatter(DemandData15,WindData15, xlabel="Demand [p.u.]", ylabel = "Wind [p.u.]", label = "", markersize = 16)

    Points = [DemandData15 WindData15]

    points = N -> [Points[i,:] for i in 1:N]
    v = points(15)
    hull = convex_hull(v)
    K = length(hull)

    plot!(p, VPolygon(hull), alpha=0.2, line =4)
    Hull = hull2array(hull)
    scatter!(p, Hull[:,1], Hull[:,2], color = :red, markersize= 16 , label = "")
    display(p)
    savefig(figsDir*"/15Hull.pdf")

# Plotting RES scenarios and its convex hull
Points = WindData[1:2,1:50]
fig = plot(Points, xlabel="Hour", ylabel = "RES [p.u.]", label = "", line = 4)

v = vrep(Points')

    # Constructs a polyhedon from this V-representation with the QHull library
p = polyhedron(v, QHull.Library())
    # Removing redundant points, i.e. points which are in the interior of the convex hull
removevredundancy!(p)
    # Show remaining points, i.e. the non-redundant ones
@show vrep(p)
    # Show the H-representation, the facets describing the polytope
@show hrep(p)
hull = vrep(p)
    # plot!(p, VPolygon(hull), alpha=0.2, line =4)
    # Hull = hull2array(hull)
plot(p, color = :red , label = "Convex Hull")
    # savefig(figsDir*"/15Hull.pdf")
