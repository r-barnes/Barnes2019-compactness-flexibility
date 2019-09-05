#!/usr/bin/env python3
import matplotlib.pyplot as plt
from matplotlib.collections import PatchCollection
from descartes import PolygonPatch
import fiona
from shapely.geometry import Polygon, MultiPolygon, shape
import sys

# def PlotDistricts(dists,filename):
#   minx = 9e99
#   miny = 9e99
#   maxx = -9e99
#   maxy = -9e99
#   for i,dist in enumerate(dists):
#     if isinstance(dist['geom'],shapely.geometry.Polygon):
#       this_shape = MultiPolygon([dist['geom']])
#     else:
#       this_shape = dist['geom']
#     tminx, tminy, tmaxx, tmaxy = this_shape.bounds
#     minx = min(minx,tminx)
#     miny = min(miny,tminy)
#     maxx = max(maxx,tmaxx)
#     maxy = max(maxy,tmaxy)
#   fig = plt.figure()
#   for i,dist in enumerate(dists):
#     if isinstance(dist['geom'],shapely.geometry.Polygon):
#       this_shape = MultiPolygon([dist['geom']])
#     else:
#       this_shape = dist['geom']
#     ax   = fig.add_subplot(len(dists),1,i+1)
#     w, h = maxx - minx, maxy - miny
#     ax.set_xlim(minx - 0.05 * w, maxx + 0.05 * w)
#     ax.set_ylim(miny - 0.05 * h, maxy + 0.05 * h)
#     ax.set_aspect(1)
#     ax.axis('off')
#     patches = [PolygonPatch(p, fc="black", ec='#555555', alpha=1., zorder=1) for p in this_shape]
#     ax.add_collection(PatchCollection(patches, match_original=True))
#   plt.tight_layout(pad=0, w_pad=0, h_pad=0)
#   plt.savefig(filename, alpha=True, dpi=300)
#   plt.clf()
#   plt.cla()
#   plt.close()





def PlotDistricts(dists,filename):
  minx = 9e99
  miny = 9e99
  maxx = -9e99
  maxy = -9e99
  for i,dist in enumerate(dists):
    if isinstance(dist['geom'],Polygon):
      this_shape = MultiPolygon([dist['geom']])
    else:
      this_shape = dist['geom']
    tminx, tminy, tmaxx, tmaxy = this_shape.bounds
    minx = min(minx,tminx)
    miny = min(miny,tminy)
    maxx = max(maxx,tmaxx)
    maxy = max(maxy,tmaxy)
  for i,dist in enumerate(dists):
    fig = plt.figure()
    if isinstance(dist['geom'],Polygon):
      this_shape = MultiPolygon([dist['geom']])
    else:
      this_shape = dist['geom']
    ax   = fig.add_subplot(1,1,1)
    w, h = maxx - minx, maxy - miny
    ax.set_xlim(minx - 0.0 * w, maxx + 0.0 * w)
    ax.set_ylim(miny - 0.0 * h, maxy + 0.0 * h)
    ax.set_aspect(1)
    ax.axis('off')
    patches = [PolygonPatch(p, fc="black", ec='#555555', alpha=1., zorder=1) for p in this_shape]
    ax.add_collection(PatchCollection(patches, match_original=True))
    plt.savefig(filename.format(i=i), alpha=True, dpi=300, bbox_inches='tight')
    plt.clf()
    plt.cla()
    plt.close()
