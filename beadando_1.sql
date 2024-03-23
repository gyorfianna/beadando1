-- 1.1.
-- Irassuk a szálláshelyek neveit, típusait és a csillagok számát

SELECT SZALLAS_NEV, tipus, csillagok_szama
FROM Szallashely 
GROUP BY GROUPING SETS((SZALLAS_NEV), (tipus), (csillagok_szama)) 


-- 1.2.
-- Listázzuk ki, melyik évben hány foglalás volt. A végére összesítsük, hogy mennyi foglalás volt.

SELECT (
CASE GROUPING(YEAR(METTOL)) WHEN 0 THEN CAST(YEAR(METTOL)
AS nvarchar(4)) WHEN 1 THEN 'Összesen' END
)
AS Év,
COUNT(*) AS 'Foglalások darabszáma'
FROM Foglalas
GROUP BY ROLLUP(YEAR(METTOL))


-- 1.3.
-- Listázzuk ki, hogy csillagok számaként hány szálloda van. Rendezzük a csillagok száma szerint.

SELECT IIF(GROUPING(csillagok_szama)=1, 'Összesen', CAST(csillagok_szama AS nvarchar(4)))
        AS 'Csillagok száma', 
        COUNT(*) AS 'Szálláshelyek darabszáma'
 FROM Szallashely
 GROUP BY ROLLUP(CSILLAGOK_SZAMA)
 ORDER BY [Csillagok száma]


-- 2.1
-- Listázzuk ki a vendégek neveit és felhasználó neveit. Az adott sorban irassuk ki az előző -, majd a kövekező vendég felsorolt adatait.

SELECT NEV, USERNEV, 
       LAG(NEV,1,'Nincs') OVER(Order by NEV) AS 'Előző vendég',
	   LEAD(NEV,1,'Nincs') OVER(Order by NEV) AS 'Következő vendég'
FROM Vendeg
ORDER BY NEV


-- 2.2.
-- Listázzuk ki, hogy hány férőhely van szobánként és szállásoknént!

SELECT DISTINCT Szallashely.SZALLAS_NEV, CONVERT(int, Szoba.SZOBA_SZAMA) as 'Szoba_szama', 
       szoba.FEROHELY
	   AS 'Férőhelyek szobánként',
	   SUM(Szoba.FEROHELY) OVER( 
	   PARTITION BY Szallashely.SZALLAS_NEV)
	   AS 'Férőhely szállásonként' 
FROM Szoba JOIN Szallashely ON Szoba.SZALLAS_FK = Szallashely.SZALLAS_ID
ORDER BY Szallashely.SZALLAS_NEV, Szoba_szama


-- 3.1
-- Készítsünk tárolt eljárást username szerint és listázza ki a fogadásait

use sqlgyak
CREATE PROCEDURE dbo.UsernevFoglalasok
@username nvarchar(20)
AS

BEGIN
SELECT SZOBA_FK, METTOL, MEDDIG
FROM Foglalas
WHERE UGYFEL_FK = @username
END

EXEC dbo.UsernevFoglalasok 'adam1'


-- 4.1
-- Készítsünk egy ideiglenes táblát, aminek az egyik oszlopa XML típusú, töltsük fel három sorral, majd írassuk ki az XML típusú oszlop adatait

create table #arak
(
szallas_id int IDENTITY(1, 1),
szallas_nev NVARCHAR(20),
hely NVARCHAR(20),
ar_fokent XML
)

insert into #arak values ('Bagoly Hotel', 'Pest vármegye', 
'<Ar_fokent>1 krajcar</Ar_fokent>')

insert into #arak values ('Sába-Ház', 'Békés vármegye', 
'<Ar_fokent>5 krajcar</Ar_fokent>')

insert into #arak values ('Gold Hotel', 'Budapest', 
'<Ar_fokent>3 krajcar</Ar_fokent>')

SELECT 
[ar_fokent].value('(/Ar_fokent/node())[1]', 'nvarchar') as 'Ár (krajcár)' 
FROM #arak






