# JuliaAstroToolBox

A small collection of tools for astronomers

# Crossmatch.jl

 Astronomical catalogues cross-matching.  J. Vanderplas Python code
 ported to Julia.
 https://github.com/astroML/astroML/blob/master/astroML/crossmatch.py

# queryVizieR.jl

Query any catalogue from the [CDS VizieR database](http://vizier.u-strasbg.fr/viz-bin/VizieR)
New: now queryVizieR.jl can use filters to select sources based on a
given set of conditions! See examples below.

## Examples:
Query 2MASS PSC (VizieR = II/246/out) in a box of 1.0x1.5 degrees
around the Pleiades, retrieve default columns, keep only results with Qflg=AAA.
```
query_vizier("II/246/out",56.7500,24.116,1.0,1.5, outname="Pleiades.fits",filter=Dict("Qflg"=>"AAA"))
```
Query SDSS DR9 (VizieR = V/139/sdss9) in a box of 0.5x0.5 degrees around M42 (RA=83.8221, Dec=-05.3911)
Retrieve only RAJ2000, DEJ2000, imag, e_imag
```
query_vizier("V/139/sdss9",83.8221,-05.3911,0.5,0.5,out=["RAJ2000","DEJ2000","imag","e_imag"],outname="M42.fits")
```

