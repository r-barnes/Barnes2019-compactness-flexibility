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
  if target_srs=='local_lcc': 
    minx,miny,maxx,maxy = shp.bounds
    target_srs = "+proj=lcc +lat_1={lat1} +lat_2={lat2} +lat_0={lat0} +lon_0={lon0} +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs"
    target_srs = target_srs.format(lat1=miny,lat2=maxy,lat0=(maxy+miny)/2,lon0=(maxx+minx)/2)
  elif target_srs=='local_alb':
    minx,miny,maxx,maxy = shp.bounds
    target_srs = "+proj=aea +lat_1={lat1} +lat_2={lat2} +lat_0={lat0} +lon_0={lon0} +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
    target_srs = target_srs.format(lat1=miny,lat2=maxy,lat0=(maxy+miny)/2,lon0=(maxx+minx)/2)
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

if len(sys.argv)!=2:
  print("Calculate the effect of using different projections")
  print("Syntax: {0} <Input Shapefile>".format(sys.argv[0]))
  sys.exit(-1)

print("Calculating projection effects...")

#Load data from shapefile
in_filename = sys.argv[1]
in_fiona    = fiona.open(in_filename)
in_prj      = in_fiona.crs
dists       = [x for x in in_fiona]
for d in dists:
  d['geometry'] = shapely.geometry.shape(d['geometry'])

#A list of reasonable projections of the US
projections = [
  ('input',       'input',    in_prj), 
  ('local_lcc',   'local',    'local_lcc'),
  ('local_alb',   'local',    'local_alb'),
  ('mercator',    'global',   '+proj=merc'),
  ('robinson',    'global',   '+proj=robin'),
  ('mollweide',   'global',   '+proj=moll'),
  ('gall',        'global',   '+proj=gall'),
  ('EPSG:102003', 'conus',    '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs'), #EPSG:102003 USA_CONUS_Albers_Equal_Area_Conic
  ('EPSG:102004', 'conus',    '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs'),       #EPSG:102004 USA_CONUS_Lambert_Conformal_Conic
  ('EPSG:102005', 'conus',    '+proj=eqdc +lat_0=39 +lon_0=-96 +lat_1=33 +lat_2=45 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs'),      #EPSG:102005 USA_CONUS_Equidistant_Conic
  ('GS50',        'national', '+proj=gs50')
]

#List of dictionaries that we'll late convert to a data frame
data = [] 

#Reproject each district into one of several reasonable projections. Gather the
#resulting scores.
for d in dists:
  print(GetDistrictID(d)) #Display progress
  for p in projections:
    reprojected     = Reproject(d['geometry'], in_prj, p[2])                   #Reproject district
    gj              = json.dumps(shapely.geometry.mapping(reprojected))        #Convert district to GeoJSON
    scores          = json.loads(mander.getUnboundedScoresForGeoJSON(gj))["0"] #Get scores for district using mander
    scores['id']    = GetDistrictID(d)                                         #Save id to scores
    scores['proj']  = p[0]                                                     #Save projection to scores
    scores['ptype'] = p[1]
    data.append(scores)

#Melt data frame into the tidy format, suitable for plotting with ggplot
df = pd.DataFrame(data)
df = pd.melt(df, id_vars=['id', 'proj', 'ptype'])

#Save results
df.to_csv('output/out_projections.csv', index=False)
