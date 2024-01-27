# culture="en-US"
ConvertFrom-StringData @'
    outputfolderpatherror = OutputFolderPath {0} is not a valid folder path.
    runasadmin = The requested operation requires elevation: Run PowerShell console as administrator
    signaturerequirements = New-ADDiagram : AuthorName and CompanyName must be defined if the Signature option is specified
    forestgraphlabel = Active Directory Forest Architecture
    domaingraphlabel = Active Directory Domain Architecture
    emptyForest = No Forest Infrastructure available to diagram
    psSession = Clearing PowerShell Session {0}
    cimSession = Clearing CIM Session {0}
'@