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
import re
import os.path
import pickle

import districtplot
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

data = pickle.load(open('output/out_simplify_together.pickle', 'rb'))

if sys.argv[1][0:2]=="-p":
  print("Building images...")
  order = {'500k':1,'5m':2,'20m':3}
  ids   = set([x['id'] for x in data])
  for tp in ids:
    if os.path.exists('res_book/img_st_{0}_0.png'.format(tp)) and os.path.exists('res_book/img_st_{0}_1.png'.format(tp)) and os.path.exists('res_book/img_st_{0}_2.png'.format(tp)):
      continue
    print(tp)
    dists_to_plot = sorted([x for x in data if x['id'] == tp], key=lambda x: order[x['res']])
    districtplot.PlotDistricts(dists_to_plot, 'res_book/img_st_{0}_{{i}}.png'.format(tp))

  entry = """
  \\begin{{minipage}}{{\columnwidth}}
  \\begin{{tabular}}{{ccc}}
  \\includegraphics[width=2cm]{{img_st_{fname}_0.png}} &
  \\includegraphics[width=2cm]{{img_st_{fname}_1.png}} &
  \\includegraphics[width=2cm]{{img_st_{fname}_2.png}} \\\\
  \\pscore{{{pscore0}}} & \pscore{{{pscore1}}} & \pscore{{{pscore2}}} \\\\
  \\cscore{{{cscore0}}} & \cscore{{{cscore1}}} & \cscore{{{cscore2}}}
  \\end{{tabular}}
  \\imtitle{{{dname}}}
  \\end{{minipage}}
  """

  print("Printing book...")
  fout = open('res_book/entries.tex', 'w')
  ids = list(set([x['id'] for x in data]))
  ids.sort()
  oldname = None
  for tp in ids:
    print(tp)
    dists_to_plot = sorted([x for x in data if x['id'] == tp], key=lambda x: order[x['res']])
    if len(dists_to_plot)<3:
      continue
    if oldname!=dists_to_plot[0]['name'][0:5]:
      this_name = dists_to_plot[0]['name']
      oldname   = this_name[0:5]
      fout.write('\\bchap{{{0}}}'.format(this_name[0:this_name.find('#')-1]))
    fout.write(entry.format(
      fname   = tp,
      dname   = dists_to_plot[0]['name'].replace('#',''),
      pscore0 = dists_to_plot[0]['PolsbyPopp'],
      pscore1 = dists_to_plot[1]['PolsbyPopp'],
      pscore2 = dists_to_plot[2]['PolsbyPopp'],
      cscore0 = dists_to_plot[0]['ConvexHull'],
      cscore1 = dists_to_plot[1]['ConvexHull'],
      cscore2 = dists_to_plot[2]['ConvexHull']
    ))
  fout.close()
  del fout