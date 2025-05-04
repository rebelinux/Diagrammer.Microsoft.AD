﻿# culture="es-ES"
ConvertFrom-StringData @'
    genMain = Por favor espere mientras se genera el diagrama: {0}
    gereratingDiag= Generando diagrama de {0}
    diagramSignature = No se ha especificado la firma del diagrama
    genDiagramSignature = Generando Subgráfica de la firma
    genDiagramMain = Generando Subgráfica Principal
    osType = {0} es requerido para ejecutar Diagrammer.Microsoft.AD. Ejecute 'Install-WindowsFeature -Name '{0}'' para instalar los módulos requeridos. https://github.com/rebelinux/Diagrammer.Microsoft.AD
    outputfolderpatherror = OutputFolderPath {0} no es una ruta de carpeta válida.
    runasadmin = La operación solicitada requiere elevación: Ejecute la consola de PowerShell como administrador
    signaturerequirements = New-ADDiagram : AuthorName y CompanyName deben estar definidos si se especifica la opción de firma
    psSessionClear = Limpiando la sesión de PowerShell {0}
    psSessionSetup = Configurando la sesión de PowerShell para {0}
    unableToConnect = No se puede conectar al servidor de controlador de dominio {0}.
    InfoProject = Informacion: Consulte el sitio web de Diagrammer.Microsoft.AD en GitHub para obtener información más detallada sobre este proyecto.
    InfoDocumentation = Información: Documentación: https://github.com/rebelinux/Diagrammer.Microsoft.AD
    InfoIssues = Información: Reporte de problemas o errores: https://github.com/rebelinux/Diagrammer.Microsoft.AD/issues
    InfoCommunity = Información: Este proyecto es mantenido por la comunidad y no cuenta con patrocinio de Microsoft, sus empleados o cualquiera de sus afiliados.
    InfoVersion = Información: Diagrammer.Microsoft.AD {0} está actualmente instalado.
    WarningUpdate = Advertencia: La actualización {0} de Diagrammer.Microsoft.AD está disponible.
    WarningUpdateCommand = Advertencia: Ejecute 'Update-Module -Name Diagrammer.Microsoft.AD -Force' para instalar la última versión.

    forestgraphlabel = Arquitectura del bosque de Active Directory
    domaingraphlabel = Arquitectura del dominio de Active Directory
    emptyForest = No hay infraestructura de bosque disponible para diagramar
    fDomainNaming = Nombres de dominio
    fSchema = Esquema
    fFuncLevel = Nivel funcional
    fInfrastructure = Infraestructura
    fPDC = Emulador PDC
    fRID = RID
    fSchemaVersion = Version del esquema
    fForestRoot = Raíz del bosque
    fForestRootInfo = Informació]on de la raí]iz del bosque
    fForestRootLabel = Raiz del bosque
    fChildDomains = Dominios secundarios
    fNoChildDomains = No hay dominios secundarios

    connectingDomain = Recopilando información del dominio de Microsoft AD desde {0}.
    connectingForest = Recopilando información del bosque de Microsoft AD desde {0}.
    forestRootInfo = Información de la raíz del bosque

    DiagramLabel = Dominios secundarios
    contiguous = Contiguo
    noncontiguous = No contiguo
    osTypelast = No se puede validar si {0} está instalado.
    DiagramDummyLabel = Dominios secundarios
    NoChildDomain = No hay dominios secundarios
    funcLevel = <B>Nivel funcional</B>: {0}
    schemaVersion = <B>Versión del esquema</B>: {0}
    infrastructure = <B>Infraestructura:</B> {0}
    rID = <B>RID:</B> {0}
    pdcEmulator= <B>Emulador PDC:</B> {0}
    schema = <B>Esquema:</B> {0}
    domainNaming = <B>Nombres de dominio:</B> {0}
    fsmoRoles = Roles FSMO
    MicrosoftLogo = Logo de Microsoft

    SitesDiagramDummyLabel = Sitios
    sitesgraphlabel = Topologia del sitio de Active Directory
    sitesinventorygraphlabel = Inventario del sitio de Active Directory
    NoSites = No hay topologia de sitio
    NoSiteSubnet = No hay subredes de sitio
    siteLinkCost = Costo del enlace del sitio
    siteLinkFrequency = Frecuencia del enlace del sitio
    siteLinkFrequencyMinutes = minutos
    siteLinkName = Enlace del sitio
    NoSiteDC = No hay controladores de dominio del sitio
    emptySites = No hay topologia de sitio disponible para diagramar
    connectingSites = Recopilando información de sitios de Microsoft AD desde {0}.
    buildingSites = Construyendo diagrama de sitios de Microsoft AD desde {0}.

    NoTrusts = No hay topologia de confianza
    emptyTrusts = No hay topologia de confianza disponible para diagramar
    connectingSTrusts = Recopilando información de confianza de Microsoft AD desde {0}.
    genDiagTrust = Generando diagrama de confianzas
    trustsDiagramLabel = Dominios y confianzas de Active Directory
    buildingTrusts = Construyendo diagrama de confianza de Microsoft AD desde {0}.
    trustDirection = Direccion
    trustType = Forma
    TrustAttributes = Tipo
    AuthenticationLevel = Autenticacion
    TrustRelationships = Relaciones de confianza



    Base64Output = Mostrando cadena Base64
    DiagramOutput = El diagrama de {0} '{1}' se ha guardado en '{2}'

    caDiagramLabel = Autoridad de Certificacion de Active Directory
    caStdRootCA = Autoridad de Certificacion Raiz Independiente
    caEntRootCA = Autoridad de Certificacion Raiz Empresarial
    caEntSubCA = Autoridad de Certificacion Subordinada Empresarial
    caEnterpriseCA = CA Empresarial
    caStandaloneCA = CA Independiente
    caSubordinateCA = CA Subordinada
    NoCA = No hay infraestructura de Autoridad de Certificacion
    caNotBefore = No antes de
    caNotAfter = No despues de
    caType = Tipo
    caRootCaIssuer = Emisor de CA Raiz
    caDnsName = Nombre de DNS

    DomainControllers = Controlador de dominio
    Sites = Sitios
    Subnets = Subred
'@