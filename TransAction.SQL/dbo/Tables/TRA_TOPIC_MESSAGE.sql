﻿CREATE TABLE [dbo].[TRA_TOPIC_MESSAGE] (
    [TOPIC_MESSAGE_ID]        INT            IDENTITY (1, 1) NOT NULL,
    [USER_ID]   INT            NOT NULL,
    [BODY]     TEXT NOT NULL,
    [TOPIC_ID] INT            NOT NULL,
	[DB_CREATE_TIMESTAMP] DATETIME NOT NULL, 
	[DB_CREATE_USERID] VARCHAR(30) NOT NULL, 
	[DB_LAST_UPDATE_TIMESTAMP] DATETIME NOT NULL, 
	[DB_LAST_UPDATE_USERID] VARCHAR(30) NOT NULL,
    [CONCURRENCY_CONTROL_NUMBER] BIGINT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_TOPIC_MESSAGE] PRIMARY KEY CLUSTERED ([TOPIC_MESSAGE_ID] ASC),
    CONSTRAINT [FK_TOPIC_MESSAGE_TOPIC] FOREIGN KEY ([TOPIC_ID]) REFERENCES [dbo].[TRA_TOPIC] ([TOPIC_ID]),
    CONSTRAINT [FK_TOPIC_MESSAGE_USER] FOREIGN KEY ([USER_ID]) REFERENCES [dbo].[TRA_USER] ([USER_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_TOPIC_MESSAGE_USER]
    ON [dbo].[TRA_TOPIC_MESSAGE]([USER_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_TOPIC_MESSAGE_TOPIC]
    ON [dbo].[TRA_TOPIC_MESSAGE]([TOPIC_ID] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The date and time the record was created.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_TOPIC_MESSAGE',
    @level2type = N'COLUMN',
    @level2name = N'DB_CREATE_TIMESTAMP'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The user or proxy account that created the record. ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_TOPIC_MESSAGE',
    @level2type = N'COLUMN',
    @level2name = N'DB_CREATE_USERID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The date and time the record was created or last updated.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_TOPIC_MESSAGE',
    @level2type = N'COLUMN',
    @level2name = N'DB_LAST_UPDATE_TIMESTAMP'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The user or proxy account that created or last updated the record. ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_TOPIC_MESSAGE',
    @level2type = N'COLUMN',
    @level2name = N'DB_LAST_UPDATE_USERID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Keeps travk of all the messages under a topic',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TRA_TOPIC_MESSAGE',
    @level2type = NULL,
    @level2name = NULL

	GO
	CREATE TRIGGER [dbo].[TRA_TOPIC_MESSAGE_IS_U_TR] 
   ON  [dbo].[TRA_TOPIC_MESSAGE]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @TEAM_CONC INT;
	SET @TEAM_CONC = (SELECT CONCURRENCY_CONTROL_NUMBER FROM TRA_TOPIC_MESSAGE WHERE TRA_TOPIC_MESSAGE.TOPIC_MESSAGE_ID = (SELECT TOPIC_MESSAGE_ID FROM inserted));
	DECLARE @INSERTED_CONC INT;
	SET @INSERTED_CONC = (SELECT CONCURRENCY_CONTROL_NUMBER FROM inserted);

	IF((@INSERTED_CONC) - (@TEAM_CONC) != 1)	 
	BEGIN
	RAISERROR('Concurrency Failure',16,10068);
	RETURN
	END
	
	ELSE
	BEGIN 	
	UPDATE TRA_TOPIC_MESSAGE
	SET
	TRA_TOPIC_MESSAGE.USER_ID = inserted.USER_ID,
	TRA_TOPIC_MESSAGE.BODY = inserted.BODY,
	TRA_TOPIC_MESSAGE.TOPIC_ID = inserted.TOPIC_ID,
	TRA_TOPIC_MESSAGE.DB_CREATE_TIMESTAMP =	inserted.DB_CREATE_TIMESTAMP,
	TRA_TOPIC_MESSAGE.DB_CREATE_USERID = inserted.DB_CREATE_USERID,
	TRA_TOPIC_MESSAGE.DB_LAST_UPDATE_TIMESTAMP = CURRENT_TIMESTAMP,
	TRA_TOPIC_MESSAGE.DB_LAST_UPDATE_USERID = CURRENT_USER,
	TRA_TOPIC_MESSAGE.CONCURRENCY_CONTROL_NUMBER = inserted.CONCURRENCY_CONTROL_NUMBER
	FROM TRA_TOPIC_MESSAGE 
	INNER JOIN  inserted 
	ON TRA_TOPIC_MESSAGE.TOPIC_MESSAGE_ID = inserted.TOPIC_MESSAGE_ID;	
	END

END

GO
CREATE TRIGGER [dbo].[TRA_TOPIC_MESSAGE_IS_I_TR] 
   ON  [dbo].[TRA_TOPIC_MESSAGE]
   INSTEAD OF INSERT
AS 
BEGIN
	
	SET NOCOUNT ON;
	BEGIN
	INSERT INTO TRA_TOPIC_MESSAGE(
	   [USER_ID]
      ,[BODY]
      ,[TOPIC_ID]
      ,[DB_CREATE_TIMESTAMP]
      ,[DB_CREATE_USERID]
      ,[DB_LAST_UPDATE_TIMESTAMP]
      ,[DB_LAST_UPDATE_USERID]
      ,[CONCURRENCY_CONTROL_NUMBER])
	
	SELECT 
	   [USER_ID]
      ,[BODY]
      ,[TOPIC_ID]
      ,CURRENT_TIMESTAMP
      ,CURRENT_USER
      ,CURRENT_TIMESTAMP
      ,CURRENT_USER
      ,1
	FROM inserted
	END

	
	SELECT TOPIC_MESSAGE_ID FROM dbo.TRA_TOPIC_MESSAGE WHERE @@ROWCOUNT > 0 AND TOPIC_MESSAGE_ID = SCOPE_IDENTITY() 

END;
