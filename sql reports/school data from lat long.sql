SELECT p.id, m.sch_name AS SchoolName, s.mx_id AS MaponicsID, ps.district, (CASE WHEN s.mx_id LIKE '%private%' THEN 'Private' ELSE 'Public' END) AS SchoolType, 
                  m.ed_level AS EdLevel, s.addr AS Address, s.city, s.state, s.zip, 3959 * ACOS(COS(RADIANS(p.lat)) * COS(RADIANS(s.lat)) * COS(RADIANS(s.lon) 
                  - RADIANS(p.long)) + SIN(RADIANS(p.lat)) * SIN(RADIANS(s.lat))) AS Distance, r.rating, r.url
FROM     maponics.attendancezones AS m INNER JOIN
                  PM.bi.LatLong AS p ON m.geom.STIntersects(geometry::Point(p.long, p.lat, 4326)) = 1 INNER JOIN
                  maponics.schools AS s ON m.mx_id = s.mx_id INNER JOIN
                  maponics.gsIdMatch AS i ON i.nces_code = s.nces_schid INNER JOIN
                  maponics.GreatSchoolsRating AS r ON r.universal_id = i.universal_id INNER JOIN
                  maponics.publicschools AS ps ON ps.mx_id = s.mx_id
WHERE  (p.lat IS NOT NULL) AND (p.long IS NOT NULL)