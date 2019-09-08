#!/usr/bin/env python3

import fiona
import functools
import json
import mander
import os.path
import pandas as pd
import pickle
import pyproj
import re
import shapely
import shapely.geometry
import shapely.ops
import sys

import common

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

def GetResFromName(filename):
  return re.sub(".*_","",filename)[:-4]




#################
#USER ENTRY POINT
#################

if len(sys.argv)<2:
  print("Calculate the effect of simplification from a set of successively simplified datasets")
  print("Syntax: {0} <Input Shapefiles>".format(sys.argv[0]))
  sys.exit(-1)

print("Calculating resolution simplification together...")

#List of dictionaries that we'll late convert to a data frame
data = [] 

if sys.argv[1][0:2]=="-p":
  shapefiles = sys.argv[2:]
else:
  shapefiles = sys.argv[1:]

#Simplify each district with one of several tolerances. Gather the resulting
#scores.
if not (os.path.exists('out_simplify_together.pickle') and os.path.exists('out_simplify_together.csv')):
  for filename in shapefiles:
    #Load data from shapefile
    in_fiona    = fiona.open(filename)
    in_prj      = in_fiona.crs
    dists       = [x for x in in_fiona]
    for d in dists:
      print(filename, GetDistrictID(d))
      d['geometry'] = shapely.geometry.shape(d['geometry'])
      #Project all districts to a reasonable projection for the whole US
      d['geometry'] = Reproject(d['geometry'], in_prj, '+proj=gs50')    
      gj             = json.dumps(shapely.geometry.mapping(d['geometry']))       #Convert district to GeoJSON
      scores         = json.loads(mander.getUnboundedScoresForGeoJSON(gj))["0"]  #Get scores for district using mander
      scores['id']   = GetDistrictID(d)                                          #Save id to scores
      scores['res']  = GetResFromName(filename)                                  #Save resolution to scores
      scores['geom'] = d['geometry']
      scores['name'] = common.fips[d['properties']['STATEFP']]['name']+" "+d['properties']['CD114FP']
      data.append(scores)

  df = pd.DataFrame(data)
  del df['geom']
  df = pd.melt(df, id_vars=['id', 'res', 'name'])

  #Save results
  df.to_csv('output/out_simplify_together.csv', index=False)

  pickle.dump(data, open('output/out_simplify_together.pickle', 'wb'))
