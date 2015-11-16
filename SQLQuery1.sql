USE RRS_DW

/*SCRIPT FOR HDFC REMITANCE NEERAJ GOSWAMI
CREATE TABLE T_HDFC_REM_RAW
(
	[MARCH_CODE] [varchar](50) NULL,	
	[TERMINAL_NO] [varchar](50) NULL,
	[REF_FMC] [varchar](50) NULL,
	[BAT_NBR] [varchar](50) NULL,
	[CARD_TYPE] [varchar](100) NULL,
	[CARD_NUMBER] [varchar](16) NULL,
	[TRANS_DATE] [varchar](50) NULL,
	[SETTEL_DATE] [varchar](50) NULL,
	[AUTH_CODE] [varchar](50) NULL,
	[INTL_AMT] [varchar](50) NULL,
	[DOM_AMT] [varchar](50) NULL,
	[TRAN_ID] [varchar](50) NULL,
	[UPVALUE] [varchar](50) NULL,
	[MERCHANT_TRACKID] [varchar](50) NULL,
	[MSF] [varchar](50) NULL,
	[SERVICE_TAX] [varchar](50) NULL,
	[EDU_CESS] [varchar](50) NULL,
	[NET_AMOUNT] [varchar](50) NULL,
	[DEBITCREDIT_TYPE] [varchar](50) NULL,
	[UDF1] [varchar](100) NULL,
	[UDF2] [varchar](100) NULL,
	[UDF3] [varchar](100) NULL,
	[UDF4] [varchar](1000) NULL,
	[UDF5] [varchar](100) NULL,
	[SEQUENCE_NUMBER] [varchar](50) NULL,
	[FLAT_FILE_NAME] [varchar](2000) NULL
)

CREATE TABLE T_HDFC_REM_RAW_LOG_ERROR
(
	MachineName varchar(25),
	ErrorDescription nvarchar(2000),
	FilePath nvarchar(500),
	ErrorDate datetime
)

ALTER PROCEDURE UP_HDFC_REM_RAW_LOG_ERROR
@MachineName varchar(25),
@ErrorDescription nvarchar(2000),
@FilePath nvarchar(500)	
as
begin
	INSERT INTO T_HDFC_REM_RAW_LOG_ERROR (MachineName ,ErrorDescription ,FilePath,ErrorDate ) VALUES(@MachineName ,@ErrorDescription,@FilePath,getdate())
end


CREATE FUNCTION [dbo].[DateRange]
(     
      @Increment              CHAR(1),
      @StartDate              DATETIME,
      @EndDate                DATETIME
)
RETURNS  
@SelectedRange    TABLE 
(IndividualDate DATETIME)
AS 
BEGIN
      ;WITH cteRange (DateRange) AS (
            SELECT @StartDate
            UNION ALL
            SELECT 
                  CASE
                        WHEN @Increment = 'd' THEN DATEADD(dd, 1, DateRange)
                        WHEN @Increment = 'w' THEN DATEADD(ww, 1, DateRange)
                        WHEN @Increment = 'm' THEN DATEADD(mm, 1, DateRange)
                  END
            FROM cteRange
            WHERE DateRange <= 
                  CASE
                        WHEN @Increment = 'd' THEN DATEADD(dd, -1, @EndDate)
                        WHEN @Increment = 'w' THEN DATEADD(ww, -1, @EndDate)
                        WHEN @Increment = 'm' THEN DATEADD(mm, -1, @EndDate)
                  END)
          
      INSERT INTO @SelectedRange (IndividualDate)
      SELECT DateRange
      FROM cteRange
      OPTION (MAXRECURSION 3660);
      RETURN
END
GO
*/

SELECT COUNT(*) FROM T_HDFC_REM_RAW WITH (NOLOCK)  --34114


SELECT DISTINCT  SUBSTRING([FLAT_FILE_NAME],20,9) FROM T_HDFC_REM_RAW WITH (NOLOCK) ORDER BY 1

SELECT DISTINCT  CONVERT(DATETIME,[SETTEL_DATE],103) FROM T_HDFC_REM_RAW WITH (NOLOCK) ORDER BY 1

SELECT DISTINCT SUBSTRING([FLAT_FILE_NAME],20,9) FROM T_HDFC_REM_RAW WHERE SETTEL_DATE =''

SELECT *  FROM T_HDFC_REM_RAW WHERE SETTEL_DATE =''

SELECT * FROM T_HDFC_REM_RAW WITH (NOLOCK)

--TRUNCATE TABLE T_HDFC_REM_RAW 

SELECT * FROM T_HDFC_REM_RAW_LOG_ERROR ORDER BY ERRORDATE

SELECT top 1 [FLAT_FILE_NAME] FROM T_HDFC_REM_RAW WITH (NOLOCK) ORDER BY 1

SELECT distinct SUBSTRING([FLAT_FILE_NAME],45,12) FROM T_HDFC_REM_RAW WITH (NOLOCK) ORDER BY 1

SELECT DISTINCT LEFT(SUBSTRING([FLAT_FILE_NAME],45,11), LEN(SUBSTRING([FLAT_FILE_NAME],45,11)) - 
CHARINDEX('\',REVERSE(SUBSTRING([FLAT_FILE_NAME],45,11)))) 
FROM T_HDFC_REM_RAW WITH (NOLOCK) ORDER BY 1

SELECT LEFT('Aug 2013\1\', LEN('Aug 2013\1\') - CHARINDEX('\',REVERSE('Aug 2013\1\')))

SELECT * FROM T_HDFC_REM_RAW WITH (NOLOCK) WHERE [FLAT_FILE_NAME] LIKE  '%Nov 2013%' ORDER BY 1





--- CALCULATE MISSING DATES--------------------------
-- GET MISSING DATES WITH DAY AND MONTH AND YEAR AND COPIED DATA
DECLARE @MISSINGDATES TABLE (SETTLEDDATE DATETIME,[ROW COPIED] INTEGER)

INSERT INTO @MISSINGDATES(SETTLEDDATE,[ROW COPIED])
SELECT [SETTEL_DATE]=CONVERT(DATETIME,[SETTEL_DATE],103),[ROW COPIED]=COUNT([SETTEL_DATE]) FROM T_HDFC_REM_RAW WITH (NOLOCK)
GROUP BY CONVERT(DATETIME,[SETTEL_DATE],103) 


SELECT ABC.IndividualDate,SETTLEDDATE,[DAY]=DAY(ABC.IndividualDate),[MONTH] =MONTH(ABC.IndividualDate) 
,[YEAR]=YEAR(ABC.IndividualDate),[ROW COPIED] FROM (SELECT IndividualDate FROM DateRange('d', '04/01/2014', '02/28/2015')) AS ABC
LEFT OUTER JOIN @MISSINGDATES M ON M.SETTLEDDATE = ABC.IndividualDate
WHERE SETTLEDDATE IS NULL ORDER BY [YEAR] , [MONTH],[DAY] DESC

--GET SETTLED DATES WITH COPIED ROWS

SELECT ABC.IndividualDate,SETTLEDDATE,[DAY]=DAY(ABC.IndividualDate),[MONTH] =MONTH(ABC.IndividualDate) ,[YEAR]=YEAR(ABC.IndividualDate),[ROW COPIED] 
FROM (SELECT IndividualDate FROM DateRange('d', '04/01/2014', '02/28/2015')) AS ABC
LEFT OUTER JOIN @MISSINGDATES M ON M.SETTLEDDATE = ABC.IndividualDate
WHERE SETTLEDDATE IS NOT NULL ORDER BY [YEAR] ASC,[MONTH] ASC ,[DAY] ASC
---------------------------------------------------------------------------------



