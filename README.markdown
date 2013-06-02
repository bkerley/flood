# Is it Flooding?

"Is it Flooding" is a bit of a janky, demo-ready mess right now, and
doesn't pass for a normal Rails app either. All queries are hand-rolled
SQL, ActiveRecord isn't touched, and loading data in is a bit insane.

## Dependencies

* Ruby 2.0
* Rails 4.0
* PostgreSQL 9.2
* PostGIS 2.0
* GDAL

## Postgres Configuration on Mac

This application was developed on Mac OS X, using the homebrew
package manager.

```bash
brew install gdal --with-postgres
# do the normal postgres setup here
brew install postgis
```

## Data Import

The data we use is compressed in `vendor/data`.

* `county_data.tar.bz2` is Miami-Dade County-provided data about FEMA
  Flood Zone designation (as "MultiPolygonZ") and elevation contours
  (as "MultiLineStringZ"). Right now, only the FEMA data is used 
  because converting lines into polygons isn't trivial if you don't 
  know GIS. These data are SQL ready to be loaded into PostGIS.
* `orig_kml.tar.bz2` is the KML files the above is converted from.
* `nws_precip_1day_observed_shape_20130601.tar.gz` is NWS rainfall
  observations for the entire US. It can be loaded in with GDAL's
  `ogr2ogr` tool:

  ```bash
  ogr2ogr -f PostgreSQL PG:dbname=flood-dev nws_precip_1day_observed_20130601
  ```

  It should also be indexed to provide a hilariously huge speedup:

  ```sql
  CREATE INDEX ON nws_precip_1day_observed_20130601 (lat, lon);
  ```

## Nationalizing

The rainfall data is ready for use anywhere in the US. 

The FEMA
flood zone data, however, is not. The application expects it to be
provided as polygon data in the `femafloodzone_lyr` table, and 
queryable as such:

``sql
SELECT ogc_fid, name
FROM femafloodzone_lyr
WHERE 
  ST_Within(
    ST_PointFromText(
      'POINT(-122.0312186 37.33233141)', 4326),
    wkb_geometry)
LIMIT 5;

```

This query lives in `app/models/flood_zone.rb`, should you need to
alter it.

## What's Next?

There's lots of improvements that can be made. See the
[issues list on GitHub](https://github.com/bkerley/flood/issues)
for a comprehensive list.

## Authors

* Bryce Kerley: bkerley@brycekerley.net , https://twitter.com/bonzoesc

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/deed.en_US">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>.
