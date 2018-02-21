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
    pyproj.Proj(src_srs), # source coordinate system (Default? 'epsg:4326' TODO)
    pyproj.Proj(target_srs) # destination coordinate system
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
  print("Calculate the effect of using simplification when each district is simplified independently of the others")
  print("Syntax: {0} <Input Shapefile>".format(sys.argv[0]))
  sys.exit(-1)

print("Calculating resolution simplification individually...")

#Load data from shapefile
in_filename = sys.argv[1]
in_fiona    = fiona.open(in_filename)
in_prj      = in_fiona.crs
dists       = [x for x in in_fiona]
for d in dists:
  d['geometry'] = shapely.geometry.shape(d['geometry'])
  #Project all districts to a reasonable projection for the whole US
  d['geometry'] = Reproject(d['geometry'], in_prj, '+proj=gs50')

#A list of simplification tolerances to explore (in metres)
tolerances = [0,50,100,500,1000,5000,10000]

#List of dictionaries that we'll late convert to a data frame
data = [] 

#Simplify each district with one of several tolerances. Gather the resulting
#scores.
for t in tolerances:
  for d in dists:
    print(t, GetDistrictID(d))
    distsimp      = d['geometry'].simplify(t, preserve_topology=True) #Simplify district
    gj            = json.dumps(shapely.geometry.mapping(distsimp))    #Convert district to GeoJSON
    scores        = json.loads(mander.getScoresForGeoJSON(gj))["0"]   #Get scores for district using mander
    scores['id']  = GetDistrictID(d)                                  #Save id to scores
    scores['tol'] = t                                                 #Save tolerance to scores
    data.append(scores)

df = pd.DataFrame(data)
df = pd.melt(df, id_vars=['id', 'tol'])

#Save results
df.to_csv('out_simplify_individually.csv', index=False)
