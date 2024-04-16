-- IN2090
-- "Oblig" 4
-- SQL 2

-- Oppgave 1 - Opplunking
SELECT DISTINCT firstname, lastname, parttype
FROM film JOIN filmparticipation USING (filmid)
JOIN person USING (personid)
WHERE title = 'Star Wars'
;

-- Oppgave 2 - Land
SELECT country, count(*) as ant
FROM filmcountry
GROUP BY country
ORDER BY ant DESC
;

-- Oppgave 3 - Spilletider
SELECT country, floor(avg(CAST(time AS INTEGER))) as avgtime
FROM runningtime
WHERE time  ~ '^\d+$'
AND country IS NOT NULL
GROUP BY country
HAVING count(*) > 200;

-- Oppgave 4 - Komplekse mennesker
-- To måter å gjøre det på 
SELECT title, genres
FROM film AS f JOIN (
    SELECT filmid, count(*) AS genres
    FROM filmgenre
    GROUP BY filmid
) AS maksgenres USING (filmid)
JOIN filmitem AS fi USING (filmid)
WHERE filmtype = 'C'
GROUP BY title, genres
ORDER BY genres DESC, title ASC
LIMIT 10
;

SELECT title, count(*) as genres
FROM film AS f JOIN filmitem USING (filmid)
JOIN filmgenre AS fi USING (filmid)
WHERE filmtype = 'C'
GROUP BY title, filmid
ORDER BY genres DESC, title ASC
LIMIT 10
;

-- Oppgave 5 - Land og filmvaner
-- Jeg er ikke helt sikker på om dette er måten det skulle bli løst på
-- da DISTINCT ON ikke er noe vi har lært om. 
-- Veldig nysgjerrig på hvordan spørringen skulle sett ut gitt det
-- vi allerede kan. 
WITH movprcountry AS (
    SELECT country, count(*) as ant
    FROM filmcountry
    GROUP BY country
), avgprcountry AS (
    SELECT country, round(avg(rank)::numeric, 2) as avgrank
    FROM filmrating JOIN filmcountry USING (filmid)
    GROUP BY country
    ORDER BY avgrank
), genreprcountry AS (
    SELECT DISTINCT ON (country) country, genre, count(*) as popgenre
    FROM filmcountry JOIN filmgenre USING (filmid)
    GROUP BY country, genre
    ORDER BY country, popgenre DESC
)
SELECT DISTINCT ON (country) country, ant, avgrank, genre
FROM movprcountry JOIN avgprcountry USING (country)
JOIN genreprcountry USING (country)
GROUP BY country, ant, avgrank, genre
;

-- Oppgave 6 - Vennskap
SELECT count(*), fc1.country, fc2.country
FROM filmcountry AS fc1 INNER JOIN filmcountry AS fc2 
ON fc1.filmid = fc2.filmid AND fc1.country < fc2.country 
GROUP BY  fc1.country, fc2.country
HAVING count(*) > 150
ORDER BY count(*) DESC
;

-- Oppgave 7 - Mot
SELECT DISTINCT ON(title) title, prodyear
FROM film JOIN filmgenre USING (filmid)
JOIN filmcountry USING (filmid)
WHERE (title LIKE '%Dark%' OR title LIKE '%Night%')
AND (country = 'Romania' OR genre = 'Horror')
;

-- Oppgave 8 - Lunch
SELECT title, count(filmid)
FROM filmparticipation JOIN film USING (filmid)
WHERE prodyear > 2009
GROUP BY title
HAVING count(filmid) < 3
ORDER BY count(filmid) DESC
;

-- Oppgave 9 - Introspeksjon
-- Her var jeg og medstudenter litt uenige og får ganske 
-- forskjellige svar avhengig om vi sjekker horrormovies 
-- og scifimovies opp mot film-tabellen eller filmid-
-- tabellen. Vet ikke helt hvilken av de som er riktig
-- men under ser du to varianter som gir forskjellige svar.
WITH horrormovies AS (
    SELECT filmid
    FROM filmgenre
    WHERE genre = 'Horror'
), 
scifimovies AS (
    SELECT filmid
    FROM filmgenre
    WHERE genre = 'Sci-Fi'
)
--SELECT count(distinct filmid)
--FROM film 
--EXCEPT (
--    SELECT filmid FROM horrormovies JOIN scifimovies USING (filmid)
--);
SELECT count(DISTINCT filmid)
FROM filmgenre
WHERE (filmid NOT IN (SELECT filmid FROM horrormovies)
AND filmid NOT IN (SELECT filmid FROM scifimovies))
;

-- Oppgave 10 - Kompetahseheving
-- Skjønner ikke helt hva oppgaven ber om.
-- Ga litt opp. 
WITH harrisonmovies AS (
    SELECT filmid
    FROM film JOIN filmparticipation USING (filmid)
    JOIN person USING (personid)
    JOIN filmitem USING (filmid)
    WHERE lastname = 'Ford'
    AND firstname = 'Harrison'
    AND parttype = 'cast'
    AND filmtype = 'C'
), romcoms AS (
    SELECT filmid
    FROM filmgenre JOIN filmitem USING (filmid)
    WHERE (genre = 'Comedy'
    OR genre = 'Romance')
    AND filmtype = 'C'
), interestinghmovies AS (
    SELECT filmid
    FROM harrisonmovies JOIN filmrating USING (filmid)
    WHERE votes > 1000
    AND rank > 8
    LIMIT 10
), interestingrcmovies AS (
    SELECT filmid
    FROM romcoms JOIN filmrating USING (filmid)
    WHERE votes > 1000
    AND rank > 8
    LIMIT 10
), highestranked AS (
    SELECT filmid
    FROM filmrating
    WHERE rank > 8
), highestvoted AS (
    SELECT filmid
    FROM filmrating
    WHERE votes > 1000
)
SELECT count(DISTINCT filmid)
FROM film
JOIN interestingrcmovies USING (filmid)
;