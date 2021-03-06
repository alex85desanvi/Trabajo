USE [master]
GO
/****** Object:  Database [Control_de_Inventario]    Script Date: 12/01/2019 22:09:22 ******/
CREATE DATABASE [Control_de_Inventario]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Control_de_Inventario', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Control_de_Inventario.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Control_de_Inventario_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Control_de_Inventario_log.ldf' , SIZE = 1088KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Control_de_Inventario] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Control_de_Inventario].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ARITHABORT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Control_de_Inventario] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Control_de_Inventario] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Control_de_Inventario] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET RECOVERY FULL 
GO
ALTER DATABASE [Control_de_Inventario] SET  MULTI_USER 
GO
ALTER DATABASE [Control_de_Inventario] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Control_de_Inventario] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Control_de_Inventario] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Control_de_Inventario', N'ON'
GO
USE [Control_de_Inventario]
GO
/****** Object:  StoredProcedure [dbo].[spAgregarArticulo]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAgregarArticulo](	@art_nombre varchar(50),
									@art_descripcion varchar(100),
									@art_precio_uni decimal(10,2),
									@art_precio_mayor_1 decimal(10,2),
									@art_precio_mayor_2 decimal (10,2))
AS
BEGIN
	if(@art_nombre<>'' AND @art_precio_uni<>0)
		begin
			insert into Articulo	(art_nombre,
									art_descripcion,
									art_precio_uni,
									art_precio_mayor_1,
									art_precio_mayor_2)
			values					(@art_nombre,
									@art_descripcion,
									@art_precio_uni,
									@art_precio_mayor_1,
									@art_precio_mayor_2)
		end
	else
		begin
			select 'Ingrese los campos obligatorios'
		end
END


GO
/****** Object:  StoredProcedure [dbo].[spAgregarDetalleVenta]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarDetalleVenta]	(@deta_id_detalle_venta int,
							@deta_id_articulo int,
							@deta_precio_uni decimal (10,2),
							@deta_cantidad int)
AS
BEGIN
	INSERT INTO Detalle_Venta	(deta_id_detalle_venta,
								deta_id_articulo,
								deta_precio,
								deta_cantidad)
	VALUES						(@deta_id_detalle_venta,
								@deta_id_articulo,
								@deta_precio_uni,
								@deta_cantidad)
	
	exec spInventarioSalida @deta_id_articulo,@deta_cantidad
END


GO
/****** Object:  StoredProcedure [dbo].[spAgregarEntrada]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAgregarEntrada]	(@ent_usuario int,
									@ent_cantidad int,
									@ent_articulo int)
AS
BEGIN
	DECLARE @CantidadTotal int
	IF(select COUNT(*) from Articulo where id_articulo = @ent_articulo)>0
		begin
			IF @ent_cantidad>0
				begin
					insert into Entreda(ent_fecha,
										ent_usuario,
										ent_cantidad,
										ent_articulo)
					values				(GETDATE(),
										@ent_usuario,
										@ent_cantidad,
										@ent_articulo)
					IF(select COUNT(*) from Inventario where inv_articulo = @ent_articulo)>0
						begin
							set @CantidadTotal = @ent_cantidad + (SELECT Inventario.inv_cantidad FROM Inventario WHERE inv_articulo = @ent_articulo)
							update Inventario set inv_cantidad = @CantidadTotal 
							where inv_articulo = @ent_articulo
						end
					ELSE
						begin
							insert into Inventario(inv_articulo,
										inv_cantidad,
										inv_cantidad_min,
										inv_descripcion)
							values		(@ent_articulo,
										@ent_cantidad,
										10,
										'')
						end
				end
			ELSE
				begin
					select 'Ingrese un numero mayor a 0'
				end
		end
	ELSE	
		begin	
			select 'Ingrese un articulo existente'
		end
END



GO
/****** Object:  StoredProcedure [dbo].[spAgregarUsuario]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarUsuario]	(@usu_nombre varchar(30),
									@usu_password varchar(30),
									@usu_perfil int)
AS
BEGIN
		IF(select COUNT(*) from Usuario where usu_nombre = @usu_nombre) = 0
			begin
				IF(select COUNT(*) from Perfil where id_perfil = @usu_perfil)>0
					begin
						insert into Usuario(usu_nombre,
											usu_password,
											usu_perfil,
											usu_activo)
						values				(@usu_nombre,
											@usu_password,
											@usu_perfil,
											1)
						select 'El Usuario se guardo correctamente'
					end
				ELSE
					begin
						select 'El Perfil de Usuario no existe'
					end
			end
		ELSE
			begin
				select 'El Nombre de Usuario que intenta ingresar ya existe'
			end
END


GO
/****** Object:  StoredProcedure [dbo].[spAgregarVenta]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarVenta]	(@ven_id_usuario int,
							@ven_total decimal (10,2))
AS
BEGIN
	INSERT INTO Venta	(ven_id_usuario,
						ven_fecha,
						ven_total)
	VALUES				(@ven_id_usuario,
						GETDATE(),
						@ven_total)
END


GO
/****** Object:  StoredProcedure [dbo].[spEditarUsuario]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEditarUsuario] (@id_usuario int,
								@usu_nombre varchar(30),
								@usu_password varchar(30),
								@usu_perfil int)
AS
BEGIN
			begin
				if(@usu_password <> '')
				begin
					UPDATE Usuario SET usu_password = @usu_password
					WHERE id_usuario = @id_usuario
				end
				else
				begin
					UPDATE Usuario SET	usu_nombre = @usu_nombre,usu_perfil = @usu_perfil
					WHERE id_usuario = @id_usuario
				end
			end
END

GO
/****** Object:  StoredProcedure [dbo].[spEliminarUsuario]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEliminarUsuario] (@id_usuario int)
AS
BEGIN
	UPDATE Usuario SET usu_activo = 0
	WHERE id_usuario = @id_usuario 
END


GO
/****** Object:  StoredProcedure [dbo].[spInventarioSalida]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInventarioSalida] (@inv_articulo int, 
									@inv_descontar_cantidad int)
AS 
BEGIN
	IF (select Inv.inv_cantidad from Inventario as Inv where Inv.inv_articulo = @inv_articulo)>@inv_descontar_cantidad
	begin
		update Inventario set inv_cantidad = inv_cantidad - @inv_descontar_cantidad
		where Inventario.inv_articulo = @inv_articulo
	end
	else
	begin
		print 'El cantidad del Articulo que intenta vender excede el stock'
	end
END



GO
/****** Object:  Table [dbo].[Articulo]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Articulo](
	[id_articulo] [int] IDENTITY(1,1) NOT NULL,
	[art_nombre] [varchar](50) NULL,
	[art_descripcion] [varchar](100) NULL,
	[art_precio_uni] [decimal](10, 2) NULL,
	[art_precio_mayor_1] [decimal](10, 2) NULL,
	[art_precio_mayor_2] [decimal](10, 2) NULL,
	[art_activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Detalle_Venta]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Detalle_Venta](
	[deta_id_detalle_venta] [int] NOT NULL,
	[deta_id_articulo] [int] NOT NULL,
	[deta_precio] [decimal](10, 2) NULL,
	[deta_cantidad] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[deta_id_detalle_venta] ASC,
	[deta_id_articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Entreda]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Entreda](
	[id_entrada] [int] IDENTITY(1,1) NOT NULL,
	[ent_fecha] [date] NULL,
	[ent_usuario] [int] NULL,
	[ent_cantidad] [int] NULL,
	[ent_articulo] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_entrada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Inventario]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Inventario](
	[id_inventario] [int] IDENTITY(1,1) NOT NULL,
	[inv_articulo] [int] NULL,
	[inv_cantidad] [int] NULL,
	[inv_cantidad_min] [int] NULL,
	[inv_descripcion] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_inventario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Perfil]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Perfil](
	[id_perfil] [int] IDENTITY(1,1) NOT NULL,
	[per_perfil] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_perfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Usuario](
	[id_usuario] [int] IDENTITY(1,1) NOT NULL,
	[usu_nombre] [varchar](30) NULL,
	[usu_password] [varchar](30) NULL,
	[usu_perfil] [int] NULL,
	[usu_activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Venta]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Venta](
	[id_venta] [int] IDENTITY(1,1) NOT NULL,
	[ven_id_usuario] [int] NULL,
	[ven_fecha] [date] NULL,
	[ven_total] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwmostrarusuarios]    Script Date: 12/01/2019 22:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmostrarusuarios]
as
select U.id_usuario as ID,U.usu_nombre AS USUARIO,P.per_perfil AS PERFIL from Usuario as U inner join Perfil as P
on U.usu_perfil = P.id_perfil where P.id_perfil <> 1 and U.usu_activo = 1


GO
SET IDENTITY_INSERT [dbo].[Articulo] ON 

INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (1, N'NIVEA CEREZA CREMA CORPORAL 400ML', N'CEREZA & ACEITE DE JOJOBA PIEL NORMAL A SECA', CAST(105.00 AS Decimal(10, 2)), CAST(100.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (2, N'HELBAL ESSENCES ALBOROTALOS ACONDICIONADOR 300ML', N'ALBOROTALOS CON ESECIAS DE MANGOSTAN', CAST(85.00 AS Decimal(10, 2)), CAST(80.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (3, N'PHILIP MORRIS 10', N'PHILIP MORRIS BOX 10', CAST(40.00 AS Decimal(10, 2)), CAST(39.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (4, N'PHILIP MORRIS BOX 20', N'PHILIP MORRIS BOX 20', CAST(90.00 AS Decimal(10, 2)), CAST(89.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), NULL)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (5, N'PHILIP MORRIS 20', N'PHILIP MORRIS 20', CAST(88.00 AS Decimal(10, 2)), CAST(87.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 1)
SET IDENTITY_INSERT [dbo].[Articulo] OFF
INSERT [dbo].[Detalle_Venta] ([deta_id_detalle_venta], [deta_id_articulo], [deta_precio], [deta_cantidad]) VALUES (1, 1, CAST(105.00 AS Decimal(10, 2)), 4)
INSERT [dbo].[Detalle_Venta] ([deta_id_detalle_venta], [deta_id_articulo], [deta_precio], [deta_cantidad]) VALUES (1, 2, CAST(85.00 AS Decimal(10, 2)), 2)
INSERT [dbo].[Detalle_Venta] ([deta_id_detalle_venta], [deta_id_articulo], [deta_precio], [deta_cantidad]) VALUES (1, 3, CAST(40.00 AS Decimal(10, 2)), 2)
SET IDENTITY_INSERT [dbo].[Entreda] ON 

INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (1, CAST(0x253F0B00 AS Date), 1, 80, 1)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (2, CAST(0x253F0B00 AS Date), 1, 100, 2)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (3, CAST(0x253F0B00 AS Date), 2, 20, 3)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (4, CAST(0x253F0B00 AS Date), 2, 20, 2)
SET IDENTITY_INSERT [dbo].[Entreda] OFF
SET IDENTITY_INSERT [dbo].[Inventario] ON 

INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (1, 1, 80, 10, N'')
INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (2, 2, 120, 10, N'')
INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (3, 3, 13, 10, N'')
SET IDENTITY_INSERT [dbo].[Inventario] OFF
SET IDENTITY_INSERT [dbo].[Perfil] ON 

INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (1, N'ADMINISTRADOR')
INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (2, N'MASTER')
INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (3, N'CAJERO')
SET IDENTITY_INSERT [dbo].[Perfil] OFF
SET IDENTITY_INSERT [dbo].[Usuario] ON 

INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (1, N'Alexander', N'9484', 1, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (2, N'Tato', N'9484', 2, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (3, N'Luis', N'2030', 2, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (7, N'Leo', N'123', 3, 1)
SET IDENTITY_INSERT [dbo].[Usuario] OFF
SET IDENTITY_INSERT [dbo].[Venta] ON 

INSERT [dbo].[Venta] ([id_venta], [ven_id_usuario], [ven_fecha], [ven_total]) VALUES (1, 1, CAST(0x253F0B00 AS Date), CAST(670.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [dbo].[Venta] OFF
ALTER TABLE [dbo].[Articulo] ADD  CONSTRAINT [chk_art_activo]  DEFAULT ((1)) FOR [art_activo]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [chk_usu_activo]  DEFAULT ((1)) FOR [usu_activo]
GO
ALTER TABLE [dbo].[Detalle_Venta]  WITH CHECK ADD FOREIGN KEY([deta_id_detalle_venta])
REFERENCES [dbo].[Venta] ([id_venta])
GO
ALTER TABLE [dbo].[Detalle_Venta]  WITH CHECK ADD FOREIGN KEY([deta_id_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Entreda]  WITH CHECK ADD FOREIGN KEY([ent_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Entreda]  WITH CHECK ADD FOREIGN KEY([ent_usuario])
REFERENCES [dbo].[Usuario] ([id_usuario])
GO
ALTER TABLE [dbo].[Inventario]  WITH CHECK ADD FOREIGN KEY([inv_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD FOREIGN KEY([usu_perfil])
REFERENCES [dbo].[Perfil] ([id_perfil])
GO
ALTER TABLE [dbo].[Venta]  WITH CHECK ADD FOREIGN KEY([ven_id_usuario])
REFERENCES [dbo].[Usuario] ([id_usuario])
GO
ALTER TABLE [dbo].[Inventario]  WITH CHECK ADD  CONSTRAINT [chk_inv_cantidad] CHECK  (([inv_cantidad]>=(0)))
GO
ALTER TABLE [dbo].[Inventario] CHECK CONSTRAINT [chk_inv_cantidad]
GO
USE [master]
GO
ALTER DATABASE [Control_de_Inventario] SET  READ_WRITE 
GO
