﻿CREATE TABLE [dbo].[TRA_USER] (
    [USER_ID]               INT            IDENTITY (1, 1) NOT NULL,
    [USERNAME]             VARCHAR(255) NOT NULL,
    [DIRECTORY ] VARCHAR(8) NOT NULL,
	[GUID] VARCHAR(255) NOT NULL,
    --[REGION]           VARCHAR(255) NOT NULL,
   [REGION_ID]         INT NOT NULL,
   [FNAME]            VARCHAR(255) NOT NULL,
    [LNAME]            VARCHAR(255) NOT NULL,
    [DESCRIPTION]      VARCHAR(1024) NOT NULL,
    [EMAIL]            VARCHAR(1024) NOT NULL,
    [ROLE_ID]      INT            NOT NULL,
    [TEAM_ID]       INT,
	[DB_CREATE_TIMESTAMP] DATETIME NOT NULL, 
	[DB_CREATE_USERID] VARCHAR(30) NOT NULL, 
	[DB_LAST_UPDATE_TIMESTAMP] DATETIME NOT NULL, 
	[DB_LAST_UPDATE_USERID] VARCHAR(30) NOT NULL,
     
     
    [CONCURRENCY_CONTROL_NUMBER] BIGINT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_USER] PRIMARY KEY CLUSTERED ([USER_ID] ASC),
    CONSTRAINT [FK_USER_ROLE] FOREIGN KEY ([ROLE_ID]) REFERENCES [dbo].[TRA_ROLE] ([ROLE_ID]),
    CONSTRAINT [FK_USER_TEAM] FOREIGN KEY ([TEAM_ID]) REFERENCES [dbo].[TRA_TEAM] ([TEAM_ID]),
	CONSTRAINT [FK_USER_REGION] FOREIGN KEY ([REGION_ID]) REFERENCES [dbo].[TRA_REGION] ([REGION_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_USER_ROLE]
    ON [dbo].[TRA_USER]([ROLE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_USER_TEAM]
    ON [dbo].[TRA_USER]([TEAM_ID] ASC);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The date and time the record was created.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_USER',
    @level2type = N'COLUMN',
    @level2name = N'DB_CREATE_TIMESTAMP'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The user or proxy account that created the record. ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_USER',
    @level2type = N'COLUMN',
    @level2name = N'DB_CREATE_USERID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The date and time the record was created or last updated.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_USER',
    @level2type = N'COLUMN',
    @level2name = N'DB_LAST_UPDATE_TIMESTAMP'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The user or proxy account that created or last updated the record. ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_USER',
    @level2type = N'COLUMN',
    @level2name = N'DB_LAST_UPDATE_USERID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Keeps track and contains all the information about the user',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_USER',
    @level2type = NULL,
    @level2name = NULL

	GO
CREATE TRIGGER [dbo].[TRA_USER_IS_U_TR] 
   ON  [dbo].[TRA_USER]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @TEAM_CONC INT;
	SET @TEAM_CONC = (SELECT CONCURRENCY_CONTROL_NUMBER FROM TRA_USER WHERE TRA_USER.USER_ID = (SELECT USER_ID FROM inserted));
	DECLARE @INSERTED_CONC INT;
	SET @INSERTED_CONC = (SELECT CONCURRENCY_CONTROL_NUMBER FROM inserted);

	IF((@INSERTED_CONC) - (@TEAM_CONC) != 1)	 
	BEGIN
	RAISERROR('Concurrency Failure',16,10068);
	RETURN
	END
	
	ELSE
	BEGIN 	
	UPDATE TRA_USER
	SET
	TRA_USER.USERNAME = inserted.USERNAME,
	TRA_USER.[DIRECTORY ] = inserted.[DIRECTORY ],
	TRA_USER.GUID = inserted.GUID,
	TRA_USER.REGION_ID = inserted.REGION_ID,
	TRA_USER.FNAME = inserted.FNAME,
	TRA_USER.LNAME = inserted.LNAME,
	TRA_USER.DESCRIPTION = inserted.DESCRIPTION,
	TRA_USER.EMAIL = inserted.EMAIL,
	TRA_USER.ROLE_ID = inserted.ROLE_ID,
	TRA_USER.TEAM_ID = inserted.TEAM_ID,
	TRA_USER.DB_CREATE_TIMESTAMP =	inserted.DB_CREATE_TIMESTAMP,
	TRA_USER.DB_CREATE_USERID = inserted.DB_CREATE_USERID,
	TRA_USER.DB_LAST_UPDATE_TIMESTAMP = CURRENT_TIMESTAMP,
	TRA_USER.DB_LAST_UPDATE_USERID = CURRENT_USER,
	TRA_USER.CONCURRENCY_CONTROL_NUMBER = inserted.CONCURRENCY_CONTROL_NUMBER
	FROM TRA_USER 
	INNER JOIN  inserted 
	ON TRA_USER.USER_ID = inserted.USER_ID;	
	END

END

GO
CREATE TRIGGER [dbo].[TRA_USER_IS_I_TR] 
   ON  [dbo].[TRA_USER]
   INSTEAD OF INSERT
AS 
BEGIN
	
	SET NOCOUNT ON;
	BEGIN
	INSERT INTO TRA_USER(
	   [USERNAME]
      ,[DIRECTORY ]
      ,[GUID]
      ,[REGION_ID]
      ,[FNAME]
      ,[LNAME]
      ,[DESCRIPTION]
      ,[EMAIL]
      ,[ROLE_ID]
      ,[TEAM_ID]
      ,[DB_CREATE_TIMESTAMP]
      ,[DB_CREATE_USERID]
      ,[DB_LAST_UPDATE_TIMESTAMP]
      ,[DB_LAST_UPDATE_USERID]
      ,[CONCURRENCY_CONTROL_NUMBER])
	
	SELECT 
	   [USERNAME]
      ,[DIRECTORY ]
      ,[GUID]
      ,[REGION_ID]
      ,[FNAME]
      ,[LNAME]
      ,[DESCRIPTION]
      ,[EMAIL]
      ,[ROLE_ID]
      ,[TEAM_ID]
      ,CURRENT_TIMESTAMP
      ,CURRENT_USER
      ,CURRENT_TIMESTAMP
      ,CURRENT_USER
      ,1
	FROM inserted
	END

	
	SELECT USER_ID FROM dbo.TRA_USER WHERE @@ROWCOUNT > 0 AND USER_ID = SCOPE_IDENTITY() 

END;