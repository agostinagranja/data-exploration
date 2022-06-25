-- Employee data exploration

SELECT 
	*
FROM
	Employees
ORDER BY
	[Fecha de Ingreso]

-- Create View with new employees and departures per month

DROP VIEW IF EXISTS hiringsDepartures

CREATE VIEW hiringsDepartures AS
WITH CTE_hirings (yearMonth,newEmployees) AS
(
SELECT 
	FORMAT([Fecha de Ingreso],'yyyy-MM') yearMonth
	, COUNT([Fecha de Ingreso]) newEmployees
FROM 
	Employees
WHERE 
	[Fecha de Ingreso] IS NOT NULL
GROUP BY
	FORMAT([Fecha de Ingreso],'yyyy-MM')
),

CTE_departures (yearMonth, departures) AS
(
SELECT 
	FORMAT([Fecha de Egreso],'yyyy-MM') yearMonth
	, COUNT([Fecha de Egreso]) departures
FROM 
	Employees
WHERE 
	[Fecha de Egreso] IS NOT NULL
GROUP BY
	FORMAT([Fecha de Egreso],'yyyy-MM')
)

SELECT 
	CONVERT(VARCHAR(7),ISNULL(CTE_hirings.yearMonth,CTE_departures.yearMonth)) yearMonth
	, CTE_hirings.newEmployees
	, CTE_departures.departures
FROM 
	CTE_hirings
	FULL JOIN CTE_departures
		ON CTE_hirings.yearMonth = CTE_departures.yearMonth
--ORDER BY 
--	ISNULL(CTE_hirings.yearMonth,CTE_departures.yearMonth) 


-- Create View with payroll 

DROP VIEW IF EXISTS payroll

CREATE VIEW payroll AS
SELECT
	yearMonth
	, newEmployees
	, departures
	, SUM(ISNULL(newEmployees,0) - ISNULL(departures,0)) OVER (ORDER BY yearMonth) payroll
FROM
	hiringsDepartures
GROUP BY
	yearMonth
	, newEmployees
	, departures

SELECT 
	*
FROM 
	payroll

