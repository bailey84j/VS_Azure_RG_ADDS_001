Configuration Main
{
	Param(
		[string] $NodeName,

		[Parameter(Mandatory)]
		[String]$FQDomainName,

		[Parameter(Mandatory)]
		[PSCredential]$DomainAdmin1Creds,

		[Parameter(Mandatory)]
		[PSCredential]$AdminUser1Creds,

		[Int]$RetryCount=5,
		[Int]$RetryIntervalSec=30
		)

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xActiveDirectory,`
								xComputerManagement,`
                                    xNetworking,
									xStorage
 
Node $AllNodes.Where{$_.Role -eq "DC"}.Nodename
       {
		LocalConfigurationManager 
        {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true  
			AllowModuleOverwrite = $true
        }

        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }

        xDisk ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = 'F'
        }

		# Add DNS
		WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        # Install the Windows Feature for AD DS
        WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }

        # Make sure the Active Directory GUI Management tools are installed
        WindowsFeature ADDSTools            
        {             
            Ensure = 'Present'             
            Name = 'RSAT-ADDS'             
        }           

        # Create the ADDS DC
        xADDomain FirstDC {
            DomainName = $FQDomainName
            DomainAdministratorCredential = $DomainAdmin1Creds
            SafemodeAdministratorPassword = $DomainAdmin1Creds
			DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall'
        }   
        
        xWaitForADDomain DscForestWait
        {
            DomainName = $FQDomainName
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = '[xADDomain]FirstDC'
        } 

        #
        xADRecycleBin RecycleBin
        {
           EnterpriseAdministratorCredential = $DomainAdmin1Creds
           ForestFQDN = $FQDomainName
           DependsOn = '[xADDomain]FirstDC'
        }
        
        # Create an admin user so that the default Administrator account is not used
        xADUser FirstUser
        {
            DomainAdministratorCredential = $DomainAdmin1Creds
            DomainName = $FQDomainName
            UserName = $AdminUser1Creds.UserName
            Password = $AdminUser1Creds
            Ensure = 'Present'
            DependsOn = '[xADDomain]FirstDC'
        }
        
        xADGroup AddToDomainAdmins
        {
            GroupName = 'Domain Admins'
            MembersToInclude = $AdminUser1Creds.UserName
            Ensure = 'Present'
            DependsOn = '[xADUser]FirstUser'
        }     
    }

}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
Configuration Main
{
	Param(
		[string] $NodeName,
 
		[Parameter(Mandatory)]
		[String]$FQDomainName,
 
		[Parameter(Mandatory)]
		[PSCredential]$DomainAdmin1Creds,
 
		[Parameter(Mandatory)]
		[PSCredential]$AdminUser1Creds,
 
		[Int]$RetryCount=5,
		[Int]$RetryIntervalSec=30
		)
 
Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xActiveDirectory, `
                                    xComputerManagement, `
                                    xNetworking,
									xStorage
 
Node $AllNodes.Where{$_.Role -eq "DC"}.Nodename
       {
		LocalConfigurationManager 
        {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true  
			AllowModuleOverwrite = $true
        }
 
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
        }
 
        xDisk ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = 'F'
        }
 
		# Add DNS
		WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }
 
        # Install the Windows Feature for AD DS
        WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
 
        # Make sure the Active Directory GUI Management tools are installed
        WindowsFeature ADDSTools            
        {             
            Ensure = 'Present'             
            Name = 'RSAT-ADDS'             
        }           
 
        # Create the ADDS DC
        xADDomain FirstDC {
            DomainName = $FQDomainName
            DomainAdministratorCredential = $DomainAdmin1Creds
            SafemodeAdministratorPassword = $DomainAdmin1Creds
			DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall'
        }   
        
        xWaitForADDomain DscForestWait
        {
            DomainName = $FQDomainName
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = '[xADDomain]FirstDC'
        } 
 
        #
        xADRecycleBin RecycleBin
        {
           EnterpriseAdministratorCredential = $DomainAdmin1Creds
           ForestFQDN = $FQDomainName
           DependsOn = '[xADDomain]FirstDC'
        }
        
        # Create an admin user so that the default Administrator account is not used
        xADUser FirstUser
        {
            DomainAdministratorCredential = $DomainAdmin1Creds
            DomainName = $FQDomainName
            UserName = $AdminUser1Creds.UserName
            Password = $AdminUser1Creds
            Ensure = 'Present'
            DependsOn = '[xADDomain]FirstDC'
        }
        
        xADGroup AddToDomainAdmins
        {
            GroupName = 'Domain Admins'
            MembersToInclude = $AdminUser1Creds.UserName
            Ensure = 'Present'
            DependsOn = '[xADUser]FirstUser'
        }     
    }
 
}