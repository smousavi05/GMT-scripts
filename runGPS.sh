#!/bin/sh

########## set defaults ###########################################################
WHITE=255 EXTGRAY=250 VLTGRAY=225 LTGRAY=192 GRAY=128 BLACK=0
RED=250/0/0 DKRED=196/50/50 LTRED=250/225/225 PINK=255/225/255
YELLOW=255/255/50 ORANGE=255/192/50 PURPLE=255/50/255
BLUE=0/0/255 LTBLUE=192/192/250 VLTBLUE=225/250/250
BROWN=160/64/32 CYAN=50/255/255 GREEN=0/255/0

gmtset MEASURE_UNIT cm
gmtset COLOR_NAN 255/255/255 DOTS_PR_INCH 300 ANNOT_FONT_PRIMARY Times-Roman \
ANNOT_FONT_SIZE_PRIMARY 10 ANNOT_FONT_SIZE_SECONDARY 10 HEADER_FONT Times-Roman \
LABEL_FONT Times-Roman LABEL_FONT_SIZE 10 HEADER_FONT_SIZE 10 PAPER_MEDIA letter \
UNIX_TIME_POS 0i/-1i Y_AXIS_TYPE ver_text PLOT_DEGREE_FORMAT DF

###################################################################################
REGION=44/62/24/40
size=17c
fromXaxis=3
fromYaxis=2
title=GPS
tick='-B2/2WSen'
DEM=$(echo "../ETOPO1_Bed_g_gmt4.grd")

#################### Make a basemap ################################################
psbasemap -R${REGION} -JM${size} $tick -X${fromXaxis} -Y${fromYaxis} -K -V > $0.ps

####### Cut out the portion of elevation data from a global database ###############
grdcut $DEM -Gtopo0.grd -R

####### Make a color table ##########################################################
#makecpt -Cglobe -T-12000/12000/600 -Z > topo.cpt
# makecpt -Cglobe -T-10500/10500/600 -Z > topo.cpt
# makecpt -Csealand -T-7000/4000/600 -Z > topo.cpt
# makecpt -Cjet -T-7000/5500/500 -Z > topo.cpt
# makecpt -Cgebco > topo.cpt
# echo "-10000 150 10000 150" > topo.cpt   #gray
#grd2cpt topo0.grd -Csealand -L-8000/4000 -S-8000/4000/500 -V > topo.cpt
#grd2cpt topo0.grd -Crelief -L-10000/4000 -S-8000/4000/500 -V > topo.cpt
grd2cpt topo0.grd -Cjet -L-8000/4000 -S-8000/6000/500 -V > topo.cpt
#grd2cpt topo0.grd -Cjet -L-8000/4000 -S-10000/5500/500 -V > topo.cpt


####### Make a gradient file out of elevation data to be used as "shade" of the image
# The output intensity file is tmph.int. The "light" comes from 45 degree (Northeast)
# "N" is for normalization (otherwise the gradients will be too large). -Nt to make a
# more dramatic shade.
#####################################################################################
grdgradient topo0.grd -Gtopo.int -A45 -Nt2

##################### ploting the grd file on map ###################################
grdimage topo0.grd -Ctopo.cpt -Itopo.int -JM${size} -R${REGION} -Sb -O -K >> $0.ps

##################### cost line data  ###############################################
# pscoast -R${REGION} -JM${size} -Lf-46/38.5/37.5/500k:."Kilometers": -T-50/37/2c -W2 -K -O -V -W2 -Df -A100000000000 -K -O  >> $0.ps
pscoast -R -J -W4 -Df -Na -Lf65/12.0/9/500+lkm -Tf65/15.5/0.4i/2 -O -K >> $0.ps
psscale -D3.2/3.2/6.5/0.5 -Ctopo.cpt -B:m: -L -K -O -P >>  $out

#################### Plate Baundaries ###############################################
#psxy GSRM_plate_outlines.gmt -R -J -M -W5 -O -K >> $0.ps
#psxy PB2002_boundaries.gmt -R -J -M -W6 -O -K >> $0.ps


#################### plots pre earthquakes ##########################################
# awk '{print $1, $2, $3, $4*0.02}' $seis_data | psxy -R -J -P -Sc -O -W.001 -G128 >> $0.ps

#################### plots the moment tensor ########################################
# awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' foco.txt | psmeca -R -J -Sm0.35 -G$DKRED -T -O >> $0.ps

#################### plots GPS velocities ###########################################
psvelo GPS.txt -J -R -Se0.08/1.0/0 -G$BLACK -A0.04/0.4/0.12 -W2 -O -V -K >> $0.ps
psvelo GPS_legend_iran.txt -J -R -Se0.08/1.0/0 -G$RED -A0.04/0.4/0.12 -W2 -O -V -K >> $0.ps

#psscale -D2.0/-0.4/8.0/0.15h -B1500:Energy:/:LogE: -Ctopo.cpt -I -O >> $0.ps

open $0.ps

####### clean up ####################################################################
rm -f *.cpt *.grd *.inc *.int *.grad
