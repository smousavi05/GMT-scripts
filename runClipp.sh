#!/bin/sh

rm clip.ps clip.pdf

tick='-B2/2WSen'

## Make a basemap
psbasemap -R44/63/24/40 -JM17c $tick -P -X3.0 -Y3.0 -K > clip.ps

## Convert the xyz file into GRD file
awk '{print $1, $2, $3}' E.txt | xyz2grd -R -D:degree:degree -I0.5/0.5 -Gclip.grd

## Resample tmp.grd from coarse (0.5 deg.) into finer resolution (0.01 degree) 
grdsample clip.grd -Gcliph.grd -I0.01 -Ql/0.01 -Lx


############
grd2cpt cliph.grd -Crainbow > clip.cpt
grdgradient cliph.grd -Nt1 -A45 -Gclip.inc


# topography 
#echo "-10000 150 10000 150" > gray.cpt
#img2grd topo_8.2.img -R${REGION} -Gtopo2.grd -T1
#grdsample topo2.grd -Gtopoh.grd -I0.1 -Ql/0.1 -Lx
#grdgradient topoh.grd -Nt1 -A45 -Gtopo2.inc

#grdimage topoh.grd -Itopo2.inc -JM17c -Cgray.cpt -O -K >> clip.ps
grdimage cliph.grd -Iclip.inc -JM17c -Cclip.cpt -P -O -K >> clip.ps

pscoast -R -J -O -W4 -N1 -A1000 -Df -B2/2WSen:."Energy": -K >> clip.ps


makecpt -Crainbow -T9.0/18.97/0.1 -Z > tmp.cpt

psscale -D3.5/-1.5/8.0/0.3h -Ctmp.cpt -B2f18.97/:LogM0: -I -O >> clip.ps
##############

# ps2pdf clip.ps
open clip.ps
#clean up 
rm -f *.cpt *.grd *.int *.inc


