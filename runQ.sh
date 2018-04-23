#!/bin/bash
rm bVal.ps

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
out=bVal.ps
tick='-B5/5WSen'
proj="M17"
region="30/80/10/45"
infile=$(echo "LowfreQ.d.txt")
DEM=$(echo "../ETOPO1_Bed_g_gmt4.grd")

#################### Make a basemap ################################################
psbasemap -R$region -J$proj $tick -P -X2.0 -Y4 -K > $out

####### Cut out the portion of elevation data from a global database ###############
grdcut $DEM -Gtopo0.grd -R

####### Resample it ################################################################
grdsample topo0.grd -Gtopoh.grd -I0.05 -Ql/0.05 -Lx

####### Convert the xyz file into GRD file #########################################
awk '{print $1, $2, $3}' $infile | xyz2grd -R -I0.85 -Gtmp.grd
#awk '{print $1, $2, $3}' $infile | xyz2grd -R -I0.63 -Gtmp.grd # Mc comment paper

####### Resample tmp.grd from coarse (1.0 deg.) into finer resolution (0.5 degree) using grdsample.
grdsample tmp.grd -Gtmph.grd -I0.05 -Ql/0.05 -Lx

####### Make a color table ##########################################################
max=`sort -nk 3 $infile | tail -n 1 | awk '{print $3}'`
makecpt -Cseis -T100/800/5 -I >tmp.cpt
#grd2cpt tmp.grd -Cseis -I > tmp.cpt
#makecpt -Cseis -T0/20/0.1 -I -Z --COLOR_NAN=grey > tmp.cpt   # seismic hazard
#makecpt -Chaxby -T0/25/1 -I -Z --COLOR_NAN=grey > tmp.cpt   # seismic hazard
#makecpt -Chot -T0/8/0.1 -I -Z --COLOR_NAN=grey > tmp.cpt   # seismic hazard
#makecpt -Cno_green -T0/5/0.1 -Z --COLOR_NAN=grey > tmp.cpt   # seismic hazard
#makecpt -Cgray -T0/5/0.1 -Z -I > tmp.cpt   # seismic hazard

####### Make a gradient file out of elevation data to be used as "shade" of the image
# The output intensity file is tmph.int. The "light" comes from 45 degree (Northeast)
# "N" is for normalization (otherwise the gradients will be too large). -Nt to make a
# more dramatic shade.
#####################################################################################
grdgradient topoh.grd -Gtopoh.int -A45 -Nt2

####### Produce the image using the resampled grd file ##############################
grdimage tmph.grd -Itopoh.int -Ctmp.cpt -R -J -O -K >> $out

####### Overlay with coastlines and political boudnaries ############################
pscoast -R -J -W3 -Df -Lf65/12.0/9/500+lkm -Tf65/15.5/0.4i/2 -N1 -A1000 -B:."$infile": -O -K >> $out

####### Plot the scale bar at the bottom of the plot ################################
psscale -D2.5/-1.0/6.0/0.30h -B100/:Q: -Ctmp.cpt -I -O >> $out

open $out

####### clean up ####################################################################
rm -f *.cpt *.grd *.inc *.int *.grad



