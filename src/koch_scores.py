#!/usr/bin/env python3

import csv
import geojson
import json
import mander
import shapely
import shapely.wkt
import sys

csv.field_size_limit(sys.maxsize)

scores = []
with open(sys.argv[1]) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    next(csv_reader) #Throw out header
    for row in csv_reader:
      level               = row[0]
      koch_wkt            = row[1]
      geom                = shapely.wkt.loads(koch_wkt)
      gj_wkt              = geojson.Feature(geometry=geom, properties={})
      gj_wkt              = geojson.FeatureCollection([gj_wkt])
      koch_score          = json.loads(mander.getUnboundedScoresForGeoJSON(str(gj_wkt)))["0"]
      koch_score["level"] = level
      koch_score["geom"]  = koch_wkt
      scores.append(koch_score)

with open(sys.argv[2], 'w') as csvfile:
  fieldnames = list(scores[0].keys())
  writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

  writer.writeheader()
  for x in scores:
    writer.writerow(x)
