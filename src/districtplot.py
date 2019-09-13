#!/usr/bin/env python3
from descartes import PolygonPatch
from matplotlib.collections import PatchCollection
from shapely.geometry import Polygon, MultiPolygon, shape
import fiona
import matplotlib.pyplot as plt
import multiprocessing
import os
import pickle
import sys



def GetDimensions(districts):
  minx = 9e99
  miny = 9e99
  maxx = -9e99
  maxy = -9e99
  for dist in districts:
    if isinstance(dist['geom'],Polygon):
      this_shape = MultiPolygon([dist['geom']])
    else:
      this_shape = dist['geom']
    tminx, tminy, tmaxx, tmaxy = this_shape.bounds
    minx = min(minx,tminx)
    miny = min(miny,tminy)
    maxx = max(maxx,tmaxx)
    maxy = max(maxy,tmaxy)

  return (minx,miny,maxx,maxy)



def PlotDistrict(district, dims, filename):
  minx,miny,maxx,maxy = dims
  fig = plt.figure()
  if isinstance(district['geom'],Polygon):
    this_shape = MultiPolygon([district['geom']])
  else:
    this_shape = district['geom']
  ax   = fig.add_subplot(1,1,1)
  w, h = maxx - minx, maxy - miny
  ax.set_xlim(minx - 0.0 * w, maxx + 0.0 * w)
  ax.set_ylim(miny - 0.0 * h, maxy + 0.0 * h)
  ax.set_aspect(1)
  ax.axis('off')
  patches = [PolygonPatch(p, fc="black", ec='#555555', alpha=1., zorder=1) for p in this_shape]
  ax.add_collection(PatchCollection(patches, match_original=True))
  print("Saving {0}".format(filename))
  plt.savefig(filename, alpha=True, dpi=300, bbox_inches='tight')
  plt.clf()
  plt.cla()
  plt.close()



def PlotDistrictsWithID(district_id):
  districts_with_id = [x for x in data if x['id'] == district_id]
  dims = GetDimensions(districts_with_id)
  for district in districts_with_id:
    filename = 'output/district_{id}_{res}.png'.format(id=district_id, res=district['res'])
    print("Plotting {0} at resolution {1} to '{2}'".format(district_id, district['res'], filename))
    if os.path.exists(filename):
      continue
    PlotDistrict(district, dims, filename)  



data = pickle.load(open('output/out_simplify_together.pickle', 'rb'))

district_ids = set([x['id'] for x in data])

if len(sys.argv)!=1:
  district_ids = [x for x in sys.argv[1:]]

pool   = multiprocessing.Pool(4)
pool.map(PlotDistrictsWithID, district_ids)
