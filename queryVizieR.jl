

using Requests
import Requests: get

"""Query any catalogue available in the VizieR database using generic URL used in ASU
See VizieR documentation for more informations (http://vizier.cfa.harvard.edu/doc/asu-summary.htx)

# Arguments
* `catalogue::Array{Float64}`: catalogue ID to query (see http://vizier.cfa.harvard.edu/viz-bin/vizHelp?cats/U.htx)
* `ra::Float64`: R.A. (J2000) of the position to query (in degrees)
* `dec::Float64`: Dec (J2000) of the position to query (in degrees)
* `width::Float64`: width of the rectangular search box (in degrees)
* `height::Float64`: height of the rectangular search box (in degrees)
* `out::Array{String}` : array specifying the result columns to list in the output. Default: default VizieR columns.
* `outname::String` : name of the output file. Default: VizieR.fits
* `filter:: Dict{String,String}` : a Dictionary of filters on the catalogue columns
# Returns
* FITS file called `outname`

# Limitations
Only a limited handful of all the available options is currently implemented:
- currently only box search (no radius)
- output file in FITS format only (generally much more compact)
- request only by equatorial coordinates in degrees. Name resolution not implemented.
- retrieve all the sources (-out.max=unlimited)

# Examples:
Query 2MASS PSC (VizieR = II/246/out) in a box of 1.0x1.5 degrees around the Pleiades, retrieve default columns, keep only results with Qflg=AAA.
```
query_vizier("II/246/out",56.7500,24.116,1.0,1.5,outname="Pleiades.fits",filter=Dict("Qflg"=>"AAA"))
```
Query SDSS DR9 (VizieR = V/139/sdss9) in a box of 0.5x0.5 degrees around M42 (RA=83.8221, Dec=-05.3911)
Retrieve only RAJ2000, DEJ2000, imag, e_imag
```
query_vizier("V/139/sdss9",83.8221,-05.3911,0.5,0.5,out=["RAJ2000","DEJ2000","imag","e_imag"],outname="M42.fits")
```

"""

function query_vizier(catalogue::String, ra::Float64, dec::Float64,width::Float64,height::Float64,
  ;equinox::String="J2000",out::Array{String}=["*"],outname::String="VizieR.fits",filter::Dict=Dict())

  # Create a string holding the center coordinates
  if signbit(dec)
    decsign="-"
  else
    decsign="+"
  end
  center=string(ra)*"%2C"*decsign*string(abs(dec))
  # Execute the query
  if isempty(filter)
      query=post("http://vizier.u-strasbg.fr/viz-bin/asu-binfits?"; data = Dict("-source" => catalogue,
        "-out.max"=>"unlimited","-out"=>join(out,","),"-c.eq"=>equinox,
        "-c"=>center,"-c.bd"=>string(width)*"x"string(width)))
  else
      query=post("http://vizier.u-strasbg.fr/viz-bin/asu-binfits?"; data = merge(Dict("-source" => catalogue,
        "-out.max"=>"unlimited","-out"=>join(out,","),"-c.eq"=>equinox,
        "-c"=>center,"-c.bd"=>string(width)*"x"string(width)),filter))
  end
  save(query, outname)
end
