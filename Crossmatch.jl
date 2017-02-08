# Astronomical catalogues cross-matching
# J. Vanderplas Python code ported to Julia:
# https://github.com/astroML/astroML/blob/master/astroML/crossmatch.py

#Pkg.add("NearestNeighbors")
using NearestNeighbors

"""Cross-match the values between X1 and X2
By default, this uses a KD Tree for speed.

# Arguments
* `X1::Array{Float64}`: first dataset, size = D x N1
* `X2::Array{Float64}`: second dataset, size = D x N2
* `max_distance::Float64` : maximum radius of search.

# Returns
* `ind::Array{Int64}`: array of indices of the closest point in X2 to each point in X1
* `dist::Array{Float64}`: array of distances of the closest point in X2 to each point in X1
Locations with no match are indicated by
    dist[i] = NaN, ind[i] = 0
If no point is within the given radius, then inf will be returned.
"""
function crossmatch(X1::Array{Float64}, X2::Array{Float64}, max_distance::Float64=Inf)
    tree = KDTree(X2)
    idxs, dists = knn(tree, X1, 1, true)
    # Convert Array{Array{Float64,1},1} to Array{Float64,2}
    dists=hcat(dists...)' ; idxs=hcat(idxs...)'
    # Replace NN further away than max_distance
    away=(dists.>max_distance)
    idxs[away]=0
    dists[away]=NaN
    return idxs, dists
end


"""Cross-match angular values between X1 and X2
using a KD Tree for speed.  Because the
KD Tree only handles cartesian distances, the angles
are projected onto a 3D sphere.

# Arguments
* `X1::Array{Float64}`: X1[1,:] is the RA, X1[2,:] is the DEC, both measured in degrees
* `X2::Array{Float64}`: X2[1,:] is the RA, X2[2,:] is the DEC, both measured in degrees
* `max_distance::Float64`: search radius, measured in degrees

# Returns:
* `ind::Array{Int64}`: array of indices of the closest point in X2 to each point in X1
* `dist::Array{Float64}`: array of distances of the closest point in X2 to each point in X1
Locations with no match are indicated by
    `dist[i] = NaN, ind[i] = 0`

If no point is within the given radius, then inf will be returned.
"""
function crossmatch_angular(X1::Array{Float64}, X2::Array{Float64}, max_distance::Float64=Inf)
    X1 = X1 .* (π / 180.)
    X2 = X2 .* (π / 180.)
    max_distance = max_distance * (π / 180.)

    # Convert 2D RA/DEC to 3D cartesian coordinates
    Y1 = transpose(hcat(cos(X1[1,:]) .* cos(X1[2,:]),
                    sin(X1[1,:]) .* cos(X1[2,:]),
                    sin(X1[2,:])))
    Y2 = transpose(hcat(cos(X2[1,:]) .* cos(X2[2,:]),
                    sin(X2[1,:]) .* cos(X2[2,:]),
                    sin(X2[2,:])))

    # law of cosines to compute 3D distance
    max_y = sqrt(2 - 2 * cos(max_distance))
    ind, dist = crossmatch(Y1, Y2, max_y)

    # convert distances back to angles using the law of tangents
    matched = isfinite(dist)
    x = 0.5 .* dist[matched]
    dist[matched] = (180. / π * 2 * atan2(x,sqrt(max(0, 1 .- x.^2))))

    return ind, dist
end
