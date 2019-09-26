USE [GBRA]
GO

/****** Object:  StoredProcedure [dbo].[SPED_GeneraArchivoECFEnTabla]    Script Date: 26/09/2019 06:49:03 ******/
DROP PROCEDURE [dbo].[SPED_GeneraArchivoECFEnTabla]
GO

/****** Object:  StoredProcedure [dbo].[SPED_GeneraArchivoECFEnTabla]    Script Date: 26/09/2019 06:49:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =========================================================================================================================
-- Prop�sito. Llama al stored procedure que genera los datos del SPED en la tabla spedtbl9000. El layout corresponde al a�o.
-- Requisito. -
--24/6/19 jcf Creaci�n
-- =========================================================================================================================

CREATE PROCEDURE [dbo].[SPED_GeneraArchivoECFEnTabla] 
	@IdCompa�ia varchar (8),
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
AS
BEGIN

	DECLARE @layout varchar(10)
	select @layout = parametros.param1
	from dbo.fSpedParametros('LAYOUTECF'+convert(varchar(4), YEAR(@FechaHasta)), 'na', 'na', 'na', 'na', 'na', 'SPED') parametros

	if (@layout = '300')		--ecf layout 3
		exec [dbo].[SPED_ArchivoTXT_ECF_v300] @IdCompa�ia, @FechaDesde, @FechaHasta; 
	else if (@layout = '400')		--ecf layout 4
		exec [dbo].[SPED_ArchivoTXT_ECF_v400] @IdCompa�ia, @FechaDesde, @FechaHasta; 
	else if (@layout = '500')		--ecf layout 5
		exec [dbo].[SPED_ArchivoTXT_ECF_l500] @IdCompa�ia, @FechaDesde, @FechaHasta; 
	else 
		INSERT INTO spedtbl9000 (LINEA,seccion, datos) 
				values(0, 'err', 'Verifique los par�metros SPED en la configuraci�n de compa��a: ' + @layout);
End


GO

