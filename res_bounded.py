#!/usr/bin/env python3

import sys
import shapely
import shapely.ops
import shapely.geometry
import functools
import fiona
import json
import mander
import pyproj
import pandas as pd

#Utility function for reprojecting a shape
def Reproject(shp, src_srs, target_srs):
  project = functools.partial(
    pyproj.transform,
    pyproj.Proj(src_srs),   #Source cooridnate system
    pyproj.Proj(target_srs) #Destination coordinate system
  )
  return shapely.ops.transform(project, shp)  # apply projection

#Abstracts district id to make switching between datasets easier
def GetDistrictID(dist):
  return dist['properties']['GEOID']
  #return dist['properties']['DIST_NUM']




#################
#USER ENTRY POINT
#################

if len(sys.argv)!=5:
  print("Calculate the effect of using bounded scores")
  print("Syntax: {0} <Districts Shapefile> <Bounding Shapefile> <Outshapefile> <Join On>".format(sys.argv[0]))
  print("\t<Join On> = Attribute name present in both shapefiles indicating which unit a district belongs to")
  sys.exit(-1)

mander.addBoundedScoresToNewShapefile(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])