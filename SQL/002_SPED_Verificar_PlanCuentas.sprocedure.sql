USE [GBRA]
GO
/****** Object:  StoredProcedure [dbo].[SPED_Verificar_PlanCuentas]    Script Date: 1/22/2017 10:31:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SPED_Verificar_PlanCuentas] 
	@Year1 as int,
	@Comentario as varchar(250) out,
	@error as int out
AS
BEGIN
	declare @c int,@actnum as varchar(50)
	set @c=isnull((select count(*) from gl10110 o where o.YEAR1 =@year1),0)+isnull((select count(*) from gl10111 o where o.YEAR1 =@year1),0)
	if @c=0
	begin
		set @Comentario='Não há movimentos contabilísticos para este ano'
		set @error=1
	end
	else
	begin
		set @error=0
	end
	if @error=0
	begin
		set @c=(select COUNT(*) from GL10110 O
		inner join gl00100 p on p.ACTINDX = o.ACTINDX
		left join SPEDtbl004 j on j.SPED_COD_CTA=p.USERDEF1
		where o.YEAR1=@Year1 and j.SPED_COD_NAT is null)+(select count(*) from GL10111 O
		inner join gl00100 p on p.ACTINDX = o.ACTINDX
		left join SPEDtbl004 j on j.SPED_COD_CTA=p.USERDEF1
		where o.YEAR1=@Year1 and j.SPED_COD_NAT is null)
		if @c=0
		begin
			set @comentario='Código de conta GP OK'
			set @error=0
		end
		else
		begin 
			declare error_cursor cursor FOR (select p.ACTNUMBR_1 from GL10110 O
				inner join gl00100 p on p.ACTINDX = o.ACTINDX
				left join SPEDtbl004 j on j.SPED_COD_CTA=p.USERDEF1
				where o.YEAR1=@Year1 and j.SPED_COD_NAT is null
				union
				select p.ACTNUMBR_1 from GL10111 O
				inner join gl00100 p on p.ACTINDX = o.ACTINDX
				left join SPEDtbl004 j on j.SPED_COD_CTA=p.USERDEF1
				where o.YEAR1=@Year1 and j.SPED_COD_NAT is null)
			OPEN ERROR_CURSOR
			FETCH NEXT FROM ERROR_CURSOR INTO @ACTNUM
			declare @errores as varchar(250)
			while @@FETCH_STATUS=0
			begin
				SET @errores=isnull(@errores,'contas ')+LTRIM(RTRIM(@ACTNUM))+', '
				FETCH NEXT FROM ERROR_CURSOR INTO @ACTNUM
			end
			CLOSE ERROR_CURSOR
			DEALLOCATE ERROR_CURSOR
			set @Comentario=@errores+' conta código de referência não existe'
			set @error=1
		end
	end
END
