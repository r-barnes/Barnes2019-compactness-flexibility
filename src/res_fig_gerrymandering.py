#!/usr/bin/env python3

import sys
import shapely
import shapely.ops
import shapely.geometry
import functools
import itertools
import multiprocessing
import fiona
import json
import mander
import pyproj
import pandas as pd
import pickle
#import code


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

def GetDistrictScores(params):
  dist  = params[0]
  proj  = params[1]
  tol   = params[2]
  ptopo = params[3]

  dist_shape = dist['geometry']
  dist_shape = Reproject(dist_shape, in_prj, proj[2])             #Reproject district
  dist_shape = dist_shape.simplify(tol, preserve_topology=ptopo)  #Simplify district
  dist_shape = json.dumps(shapely.geometry.mapping(dist_shape))   #Convert district to GeoJSON
  
  state_shape = states[dist['properties']['STATEFP']]['geometry']  #Get district's containing state
  state_shape = Reproject(state_shape, in_prj, proj[2])            #Reproject district
  state_shape = state_shape.simplify(tol, preserve_topology=ptopo) #Simplify district
  state_shape = json.dumps(shapely.geometry.mapping(state_shape))  #Convert district to GeoJSON

  #Includes unbound scores
  scores = json.loads(mander.getBoundedScoresForGeoJSON(dist_shape, state_shape, ''))["0"] #Get scores for district using mander

  scores['id']    = GetDistrictID(dist)  #Save id to scores
  scores['proj']  = proj[0]              #Save projection to scores
  scores['ptype'] = proj[1]              #Save projection type
  scores['tol']   = tol                  #Save simplification tolerance
  scores['ptopo'] = ptopo                #Save simplification topological constraint

  return scores




#################
#USER ENTRY POINT
#################

if len(sys.argv)!=3:
  print("Find the best looking compactness score for a district")
  print("Syntax: {0} <Districts Shapefile> <States Shapefile>".format(sys.argv[0]))
  sys.exit(-1)



#Load districts from shapefile
in_dist_file = sys.argv[1]
in_fiona     = fiona.open(in_dist_file)
in_prj       = in_fiona.crs
dists        = [x for x in in_fiona]
for d in dists:
  d['geometry'] = shapely.geometry.shape(d['geometry'])

#Load states from shapefile
in_states_file = sys.argv[2]
in_fiona       = fiona.open(in_states_file)
in_prj         = in_fiona.crs
states         = [x for x in in_fiona]
for s in states:
  s['geometry'] = shapely.geometry.shape(s['geometry'])

#Convert to dictionary for quick lookup with districts
states = {s['properties']['STATEFP']:s for s in states}



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

tolerances = [0,50,100,500,1000,5000]
ptopos     = [True]

params = itertools.product(dists,projections,tolerances,ptopos)



#List of dictionaries that we'll late convert to a data frame
pool   = multiprocessing.Pool(4)
scores = pool.map(GetDistrictScores, list(params))

pickle.dump(scores, open('output/res_fig_scores.pickle', 'wb'))
scores = pickle.load(open('output/res_fig_scores.pickle', 'rb'))

#Melt data frame into the tidy format, suitable for plotting with ggplot
df = pd.DataFrame(scores)
df = pd.melt(df, id_vars=['id', 'proj', 'ptype', 'ptopo', 'tol'])

#Save results
df.to_csv('output/out_fix.csv', index=False)

#Analysis continues in `make_figs.R`