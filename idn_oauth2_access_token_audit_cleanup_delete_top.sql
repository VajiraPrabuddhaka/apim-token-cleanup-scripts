CREATE PROCEDURE IDN_OAUTH2_ACCESS_TOKEN_AUDIT_CLEANUP
AS

BEGIN

-- ------------------------------------------
-- DECLARE VARIABLES
-- ------------------------------------------
DECLARE @batchSize INT;
DECLARE @chunkSize INT;
DECLARE @checkCount INT;
DECLARE @sleepTime AS VARCHAR(12);
DECLARE @rowCount INT;
DECLARE @enableLog BIT;
DECLARE @SQL NVARCHAR(MAX);
DECLARE @chunkCount INT;
DECLARE @batchCount INT;
DECLARE @deleteCount INT;

-- ------------------------------------------
-- CONFIGURABLE ATTRIBUTES
-- ------------------------------------------
SET @batchSize = 1000;      -- SET BATCH SIZE FOR AVOID TABLE LOCKS    [DEFAULT : 10000]
SET @chunkSize = 10000;      -- CHUNK WISE DELETE FOR LARGE TABLES [DEFULT : 500000]
SET @checkCount = 1; -- SET CHECK COUNT FOR FINISH CLEANUP SCRIPT (CLEANUP ELIGIBLE TOKENS COUNT SHOULD BE HIGHER THAN checkCount TO CONTINUE) [DEFAULT : 100]
SET @sleepTime = '00:00:02.000';  -- SET SLEEP TIME FOR AVOID TABLE LOCKS     [DEFAULT : 2]
SET @enableLog = 'TRUE';       -- ENABLE LOGGING [DEFAULT : FALSE]

IF (@enableLog = 1)
BEGIN
SELECT '[' + convert(varchar, getdate(), 121) + '] CLEANUP STARTED ... !' AS 'INFO LOG';
END;


---- ------------------------------------------------------
---- BATCH DELETE IDN_OAUTH2_ACCESS_TOKEN_AUDIT
---- ------------------------------------------------------

IF (@enableLog = 1)
BEGIN
SELECT '[' + convert(varchar, getdate(), 121) + '] CLEANUP ON IDN_OAUTH2_ACCESS_TOKEN_AUDIT STARTED .... !';
END


WHILE (1=1)
BEGIN
    SELECT TOP(@chunkSize) TOKEN_ID FROM IDN_OAUTH2_ACCESS_TOKEN_AUDIT
    SELECT @chunkCount =  @@rowcount;
    IF (@chunkCount < @checkCount)
    BEGIN
        DELETE TOP(@batchCount) FROM IDN_OAUTH2_ACCESS_TOKEN_AUDIT;
        SELECT @deleteCount = @@rowcount;
        IF (@enableLog = 1)
        BEGIN
            SELECT '[' + convert(varchar, getdate(), 121) + '] BATCH DELETE FINISHED ON IDN_OAUTH2_ACCESS_TOKEN_AUDIT WITH : '+CAST(@deleteCount as varchar);
        END
        IF ((@deleteCount > 0))
        BEGIN
            SELECT '[' + convert(varchar, getdate(), 121) + '] SLEEPING ...';
            WAITFOR DELAY @sleepTime;
        END
    END
    ELSE
    BEGIN
        BREAK;
    END
END

IF (@enableLog = 1)
BEGIN
SELECT '[' + convert(varchar, getdate(), 121) + '] CLEANUP ON IDN_OAUTH2_ACCESS_TOKEN_AUDIT COMPLETED .... !';
END

END
