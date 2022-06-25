--data exploration

SELECT 
	* 
FROM 
	Settlements 
ORDER BY 
	1,4

SELECT 
	* 
FROM 
	SettlementsMovements 
ORDER BY 
	1,2,3

SELECT 
	* 
FROM 
	Items
ORDER BY 
	1,2,3

SELECT 
	* 
FROM 
	ItemType
ORDER BY 
	1,2,3

SELECT 
	* 
FROM 
	ItemKind
ORDER BY 
	1,2

SELECT 
	* 
FROM 
	Employees
ORDER BY 
	1

SELECT 
	* 
FROM 
	Jobs
ORDER BY 
	1

--select data we are going to use

-- net salary with PARTITION BY

WITH settlementDetails (settlementId,settlementDescription,settlementDate, employeeFile, employeeName, employeeId, itemId, itemName, itemType, amount)
AS
(
SELECT
	m.IdLiquid settlementId
	, s.descripción settlementDescription
	, CAST(s.fecha AS DATE) settlementDate
	, m.legajo employeeFile 
	, e.Nombre employeeName
	, e.CUIL employeeId
	, m.concepto itemId
	, i.Nombre itemName
	, it.Descripcion itemType
	, m.Monto * it.Signo amount
FROM
	SettlementsMovements AS m
	LEFT JOIN
		Settlements AS s
		ON 
			m.IdLiquid = s.Id
	LEFT JOIN
		Employees AS e
		ON 
			m.legajo = e.Legajo
	LEFT JOIN
		Items i
		ON 
			m.concepto = i.Codigo	
	LEFT JOIN
		ItemType it
		ON 
			i.[Tipo de Concepto] = it.Codigo
WHERE 
	i.[Tipo de Concepto] <> '09'
--ORDER BY 
--	settlementId,employeeId,itemId
)

SELECT 
	*
	, SUM(amount) OVER (PARTITION BY employeeId ORDER BY settlementId,employeeFile,itemId) netSalary
FROM 
	settlementDetails
ORDER BY 
	settlementId,employeeFile,itemId


-- net salary with TEMP TABLE

DROP TABLE IF EXISTS #netSalary

CREATE TABLE #netSalary
(
settlementId int
, settlementDescription nvarchar(50)
, settlementDate date
, employeeFile nvarchar (5)
, employeeName nvarchar(23)
, employeeId nvarchar(13)
, itemId nvarchar(3)
, itemName nvarchar(21)
, itemType nvarchar(30)
, amount money 
)

INSERT INTO #netSalary
SELECT
	m.IdLiquid settlementId
	, s.descripción settlementDescription
	, CAST(s.fecha AS DATE) settlementDate
	, m.legajo employeeFile 
	, e.Nombre employeeName
	, e.CUIL employeeId
	, m.concepto itemId
	, i.Nombre itemName
	, it.Descripcion itemType
	, m.Monto * it.Signo amount
FROM
	SettlementsMovements AS m
	LEFT JOIN
		Settlements AS s
		ON 
			m.IdLiquid = s.Id
	LEFT JOIN
		Employees AS e
		ON 
			m.legajo = e.Legajo
	LEFT JOIN
		Items i
		ON 
			m.concepto = i.Codigo	
	LEFT JOIN
		ItemType it
		ON 
			i.[Tipo de Concepto] = it.Codigo
WHERE 
	i.[Tipo de Concepto] <> '09'
--ORDER BY 
--	settlementId,employeeId,itemId

SELECT 
	settlementDate
	, employeeId
	, itemName
	, SUM(amount) OVER (PARTITION BY employeeId ORDER BY settlementId,employeeId,itemId) netSalary
FROM 
	#netSalary
ORDER BY 
	settlementId,employeeId,itemId


-- create VIEW to store data for later visualizations

DROP VIEW IF EXISTS netSalary

CREATE VIEW netSalary AS
SELECT
	m.IdLiquid settlementId
	, s.descripción settlementDescription
	, CAST(s.fecha AS DATE) settlementDate
	, m.legajo employeeFile 
	, e.Nombre employeeName
	, e.CUIL employeeId
	, m.concepto itemId
	, i.Nombre itemName
	, it.Descripcion itemType
	, m.Monto * it.Signo amount
FROM
	SettlementsMovements AS m
	LEFT JOIN
		Settlements AS s
		ON 
			m.IdLiquid = s.Id
	LEFT JOIN
		Employees AS e
		ON 
			m.legajo = e.Legajo
	LEFT JOIN
		Items i
		ON 
			m.concepto = i.Codigo	
	LEFT JOIN
		ItemType it
		ON 
			i.[Tipo de Concepto] = it.Codigo
WHERE 
	i.[Tipo de Concepto] <> '09'
--ORDER BY 
--	settlementId,employeeId,itemId

SELECT 
	settlementDate
	, employeeId
	, itemName
	, SUM(amount) OVER (PARTITION BY employeeId ORDER BY settlementId,employeeId,itemId) netSalary
FROM 
	netSalary
ORDER BY 
	settlementId,employeeId,itemId