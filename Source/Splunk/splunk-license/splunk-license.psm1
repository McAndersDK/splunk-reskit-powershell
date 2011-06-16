
#region Splunk License

#region Get-SplunkLicenseFile

function Get-SplunkLicenseFile
{

	<# .ExternalHelp ../Splunk-Help.xml #>
	
	[Cmdletbinding()]
    Param(
	
        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
		[ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential,
        
        [Parameter()]
        [SWITCH]$All
        
    )
	
	Begin
	{
		Write-Verbose " [Get-SplunkLicenseFile] :: Starting..."
	}
	Process
	{
		Write-Verbose " [Get-SplunkLicenseFile] :: Parameters"
		Write-Verbose " [Get-SplunkLicenseFile] ::  - ComputerName = $ComputerName"
		Write-Verbose " [Get-SplunkLicenseFile] ::  - Port         = $Port"
		Write-Verbose " [Get-SplunkLicenseFile] ::  - Protocol     = $Protocol"
		Write-Verbose " [Get-SplunkLicenseFile] ::  - Timeout      = $Timeout"
		Write-Verbose " [Get-SplunkLicenseFile] ::  - Credential   = $Credential"

        if($All)
        {
            $Endpoint = '/services/licenser/licenses'
        }
        else
        {
            $Endpoint = "/services/licenser/licenses?search={0}" -f [System.Web.HttpUtility]::UrlEncode('group_id=enterprise')
        }
        Write-Verbose " [Get-SplunkLicenseFile] ::  - Endpoint   = $Endpoint"
        
		Write-Verbose " [Get-SplunkLicenseFile] :: Setting up Invoke-APIRequest parameters"
		$InvokeAPIParams = @{
			ComputerName = $ComputerName
			Port         = $Port
			Protocol     = $Protocol
			Timeout      = $Timeout
			Credential   = $Credential
			Endpoint     = $Endpoint 
			Verbose      = $VerbosePreference -eq "Continue"
		}
			
		Write-Verbose " [Get-SplunkLicenseFile] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
		try
		{
			[XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams
			if($Results -and ($Results -is [System.Xml.XmlDocument]))
			{
				foreach($Entry in $Results.feed.Entry)
				{
					$MyObj = @{}
                    $MyObj.Add('ComputerName',$ComputerName)
					Write-Verbose " [Get-SplunkLicenseFile] :: Creating Hash Table to be used to create Splunk.SDK.Splunk.Licenser.License"
					switch ($Entry.content.dict.key)
					{
						{$_.name -eq "creation_time"} 	{$Myobj.Add("CreationTime", (ConvertFrom-UnixTime $_.'#text'));continue}
			        	{$_.name -eq "expiration_time"} {$Myobj.Add("Expiration", (ConvertFrom-UnixTime $_.'#text'));continue}
			        	{$_.name -eq "features"}	    {$Myobj.Add("Features",$_.list.item);continue}
						{$_.name -eq "group_id"}		{$Myobj.Add("GroupID",$_.'#text');continue}
				        {$_.name -eq "label"}			{$Myobj.Add("Label",$_.'#text');continue}
						{$_.name -eq "license_hash"}	{$Myobj.Add("Hash",$_.'#text');continue}
				        {$_.name -eq "max_violations"}	{$Myobj.Add("MaxViolations",$_.'#text');continue}
				        {$_.name -eq "quota"}			{$Myobj.Add("Quota",$_.'#text');continue}
				        {$_.name -eq "sourcetypes"}		{$Myobj.Add("SourceTypes",$_.'#text');continue}
				        {$_.name -eq "stack_id"}		{$Myobj.Add("StackID",$_.'#text');continue}
				        {$_.name -eq "status"}			{$Myobj.Add("Status",$_.'#text');continue}
				        {$_.name -eq "type"}			{$Myobj.Add("Type",$_.'#text');continue}
						{$_.name -eq "window_period"}	{$Myobj.Add("WindowPeriod",$_.'#text');continue}
					}
					
					# Creating Splunk.SDK.ServiceStatus
				    $obj = New-Object PSObject -Property $MyObj
				    $obj.PSTypeNames.Clear()
				    $obj.PSTypeNames.Add('Splunk.SDK.Splunk.Licenser.License')
				    $obj
				}
			}
			else
			{
				Write-Verbose " [Get-SplunkLicenseFile] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
			}
		}
		catch
		{
			Write-Verbose " [Get-SplunkLicenseFile] :: Invoke-SplunkAPIRequest threw an exception: $_"
            Write-Error $
_		}
	}
	End
	{
		Write-Verbose " [Get-SplunkLicenseFile] :: =========    End   ========="
	}
} # Get-SplunkLicenseFile

#endregion Get-SplunkLicenseFile

#region Get-SplunkLicenseMessage

function Get-SplunkLicenseMessage
{
	<# .ExternalHelp ../Splunk-Help.xml #>

	[Cmdletbinding()]
    Param(

        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
		[ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential
        
    )
    Begin
	{
		Write-Verbose " [Get-SplunkLicenseMessage] :: Starting..."
	}
	Process
	{
		Write-Verbose " [Get-SplunkLicenseMessage] :: Parameters"
		Write-Verbose " [Get-SplunkLicenseMessage] ::  - ComputerName = $ComputerName"
		Write-Verbose " [Get-SplunkLicenseMessage] ::  - Port         = $Port"
		Write-Verbose " [Get-SplunkLicenseMessage] ::  - Protocol     = $Protocol"
		Write-Verbose " [Get-SplunkLicenseMessage] ::  - Timeout      = $Timeout"
		Write-Verbose " [Get-SplunkLicenseMessage] ::  - Credential   = $Credential"

		Write-Verbose " [Get-SplunkLicenseMessage] :: Setting up Invoke-APIRequest parameters"
		$InvokeAPIParams = @{
			ComputerName = $ComputerName
			Port         = $Port
			Protocol     = $Protocol
			Timeout      = $Timeout
			Credential   = $Credential
			Endpoint     = '/services/licenser/messages' 
			Verbose      = $VerbosePreference -eq "Continue"
		}
			
		Write-Verbose " [Get-SplunkLicenseMessage] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
		try
		{
			[XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams
        }
        catch
		{
			Write-Verbose " [Get-SplunkLicenseMessage] :: Invoke-SplunkAPIRequest threw an exception: $_"
            Write-Error $
_		}
        try
        {
			if($Results -and ($Results -is [System.Xml.XmlDocument]))
			{
                if($Results.feed.entry)
                {
                    foreach($Entry in $Results.feed.entry)
                    {
        				$MyObj = @{
                            ComputerName = $ComputerName
                        }
        				Write-Verbose " [Get-SplunkLicenseMessage] :: Creating Hash Table to be used to create Splunk.SDK.License.Message"
        				switch ($Entry.content.dict.key)
        				{
        		        	{$_.name -eq "category"}	{ $Myobj.Add("Category",$_.'#text')     ; continue }
        					{$_.name -eq "create_time"}	{ $Myobj.Add("CreateTime",(ConvertFrom-UnixTime $_.'#text'))   ; continue }
        			        {$_.name -eq "pool_id"}	    { $Myobj.Add("PoolID",$_.'#text')       ; continue }
                            {$_.name -eq "severity"}    { $Myobj.Add("Severity",$_.'#text')     ; continue }
                            {$_.name -eq "slave_id"}	{ $Myobj.Add("SlaveID",$_.'#text')      ; continue }
                            {$_.name -eq "stack_id"}	{ $Myobj.Add("StackID",$_.'#text')      ; continue }
        				}
        				
        				# Creating Splunk.SDK.ServiceStatus
        			    $obj = New-Object PSObject -Property $MyObj
        			    $obj.PSTypeNames.Clear()
        			    $obj.PSTypeNames.Add('Splunk.SDK.License.Message')
        			    $obj 
                    }
                }
                else
                {
                    Write-Verbose " [Get-SplunkLicenseMessage] :: No Messages Found"
                }
                
			}
			else
			{
				Write-Verbose " [Get-SplunkLicenseMessage] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
			}
		}
		catch
		{
			Write-Verbose " [Get-SplunkLicenseMessage] :: Get-SplunkDeploymentClient threw an exception: $_"
            Write-Error $
_		}
	}
	End
	{
		Write-Verbose " [Get-SplunkLicenseMessage] :: =========    End   ========="
	}

}    # Get-SplunkLicenseMessage

#endregion Get-SplunkLicenseMessage

#region Get-SplunkLicenseGroup

function Get-SplunkLicenseGroup
{
	<# .ExternalHelp ../Splunk-Help.xml #>
    [Cmdletbinding(DefaultParameterSetName="byFilter")]
    Param(

        [Parameter(Position=0,ParameterSetName="byFilter")]
        [STRING]$Filter = '.*',
	
		[Parameter(Position=0,ParameterSetName="byName")]
		[STRING]$Name,

        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
		[ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential
        
    )
    Begin
	{
		Write-Verbose " [Get-SplunkLicenseGroup] :: Starting..."
        
        $ParamSetName = $pscmdlet.ParameterSetName
        switch ($ParamSetName)
        {
            "byFilter"  { $WhereFilter = { $_.GroupName -match $Filter } } 
            "byName"    { $WhereFilter = { $_.GroupName -ceq   $Name } }
        }
        
	}
	Process
	{
		Write-Verbose " [Get-SplunkLicenseGroup] :: Parameters"
        Write-Verbose " [Get-SplunkLicenseGroup] ::  - ParameterSet = $ParamSetName"
		Write-Verbose " [Get-SplunkLicenseGroup] ::  - ComputerName = $ComputerName"
		Write-Verbose " [Get-SplunkLicenseGroup] ::  - Port         = $Port"
		Write-Verbose " [Get-SplunkLicenseGroup] ::  - Protocol     = $Protocol"
		Write-Verbose " [Get-SplunkLicenseGroup] ::  - Timeout      = $Timeout"
		Write-Verbose " [Get-SplunkLicenseGroup] ::  - Credential   = $Credential"
        Write-Verbose " [Get-SplunkLicenseGroup] ::  - WhereFilter  = $WhereFilter"

		Write-Verbose " [Get-SplunkLicenseGroup] :: Setting up Invoke-APIRequest parameters"
		$InvokeAPIParams = @{
			ComputerName = $ComputerName
			Port         = $Port
			Protocol     = $Protocol
			Timeout      = $Timeout
			Credential   = $Credential
			Endpoint     = '/services/licenser/groups' 
			Verbose      = $VerbosePreference -eq "Continue"
		}
			
		Write-Verbose " [Get-SplunkLicenseGroup] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
		try
		{
			[XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams
        }
        catch
		{
			Write-Verbose " [Get-SplunkLicenseGroup] :: Invoke-SplunkAPIRequest threw an exception: $_"
            Write-Error $
_		}
        try
        {
			if($Results -and ($Results -is [System.Xml.XmlDocument]))
			{
                if($Results.feed.entry)
                {
                    foreach($Entry in $Results.feed.entry)
                    {
        				$MyObj = @{
                            ComputerName = $ComputerName
                            GroupName    = $Entry.title
                            ID           = $Entry.link | Where-Object {$_.rel -eq "edit"} | Select-Object -expand href
                        }
        				Write-Verbose " [Get-SplunkLicenseGroup] :: Creating Hash Table to be used to create Splunk.SDK.License.Group"
        				switch ($Entry.content.dict.key)
        				{
        		        	{$_.name -eq "is_active"}	{ $Myobj.Add("IsActive",[bool]([int]$_.'#text'))  ; continue }
                            {$_.name -eq "stack_ids"}	{ $Myobj.Add("StackIDs",$_.list.item)        ; continue }
        				}
        				
        				# Creating Splunk.SDK.ServiceStatus
        			    $obj = New-Object PSObject -Property $MyObj
        			    $obj.PSTypeNames.Clear()
        			    $obj.PSTypeNames.Add('Splunk.SDK.License.Group')
        			    $obj | Where-Object $WhereFilter
                    }
                }
                else
                {
                    Write-Verbose " [Get-SplunkLicenseGroup] :: No Messages Found"
                }
                
			}
			else
			{
				Write-Verbose " [Get-SplunkLicenseGroup] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
			}
		}
		catch
		{
			Write-Verbose " [Get-SplunkLicenseGroup] :: Get-SplunkDeploymentClient threw an exception: $_"
            Write-Error $
_		}
	}
	End
	{
		Write-Verbose " [Get-SplunkLicenseGroup] :: =========    End   ========="
	}

}    # Get-SplunkLicenseGroup

#endregion Get-SplunkLicenseGroup

#region Get-SplunkLicenseStack

function Get-SplunkLicenseStack
{
	<# .ExternalHelp ../Splunk-Help.xml #>

    [Cmdletbinding(DefaultParameterSetName="byFilter")]
    Param(

        [Parameter(Position=0,ParameterSetName="byFilter")]
        [STRING]$Filter = '.*',
	
		[Parameter(Position=0,ParameterSetName="byName")]
		[STRING]$Name,

        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
		[ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential
        
    )
    Begin
	{
		Write-Verbose " [Get-SplunkLicenseGroup] :: Starting..."
        
        $ParamSetName = $pscmdlet.ParameterSetName
        switch ($ParamSetName)
        {
            "byFilter"  { $WhereFilter = { $_.StackName -match $Filter } } 
            "byName"    { $WhereFilter = { $_.StackName -ceq   $Name } }
        }
        
	}
	Process
	{
		Write-Verbose " [Get-SplunkLicenseStack] :: Parameters"
        Write-Verbose " [Get-SplunkLicenseStack] ::  - ParameterSet = $ParamSetName"
		Write-Verbose " [Get-SplunkLicenseStack] ::  - ComputerName = $ComputerName"
		Write-Verbose " [Get-SplunkLicenseStack] ::  - Port         = $Port"
		Write-Verbose " [Get-SplunkLicenseStack] ::  - Protocol     = $Protocol"
		Write-Verbose " [Get-SplunkLicenseStack] ::  - Timeout      = $Timeout"
		Write-Verbose " [Get-SplunkLicenseStack] ::  - Credential   = $Credential"
        Write-Verbose " [Get-SplunkLicenseStack] ::  - WhereFilter  = $WhereFilter"

		Write-Verbose " [Get-SplunkLicenseStack] :: Setting up Invoke-APIRequest parameters"
		$InvokeAPIParams = @{
			ComputerName = $ComputerName
			Port         = $Port
			Protocol     = $Protocol
			Timeout      = $Timeout
			Credential   = $Credential
			Endpoint     = '/services/licenser/stacks' 
			Verbose      = $VerbosePreference -eq "Continue"
		}
			
		Write-Verbose " [Get-SplunkLicenseStack] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
		try
		{
			[XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams
        }
        catch
		{
			Write-Verbose " [Get-SplunkLicenseStack] :: Invoke-SplunkAPIRequest threw an exception: $_"
            Write-Error $
_		}
        try
        {
			if($Results -and ($Results -is [System.Xml.XmlDocument]))
			{
                if($Results.feed.entry)
                {
                    foreach($Entry in $Results.feed.entry)
                    {
        				$MyObj = @{
                            ComputerName = $ComputerName
                            StackName    = $Entry.title
                            ID           = $Entry.link | Where-Object {$_.rel -eq "list"} | Select-Object -expand href
                        }
        				Write-Verbose " [Get-SplunkLicenseStack] :: Creating Hash Table to be used to create Splunk.SDK.License.Stack"
        				switch ($Entry.content.dict.key)
        				{
        		        	{$_.name -eq "label"}	{ $Myobj.Add("Label",$_.'#text') ; continue }
                            {$_.name -eq "quota"}	{ $Myobj.Add("Quota",$_.'#text') ; continue }
                            {$_.name -eq "type"}	{ $Myobj.Add("Type",$_.'#text')  ; continue }
        				}
        				
        				# Creating Splunk.SDK.License.Stack
        			    $obj = New-Object PSObject -Property $MyObj
        			    $obj.PSTypeNames.Clear()
        			    $obj.PSTypeNames.Add('Splunk.SDK.License.Stack')
        			    $obj | Where-Object $WhereFilter
                    }
                }
                else
                {
                    Write-Verbose " [Get-SplunkLicenseStack] :: No Messages Found"
                }
                
			}
			else
			{
				Write-Verbose " [Get-SplunkLicenseStack] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
			}
		}
		catch
		{
			Write-Verbose " [Get-SplunkLicenseStack] :: Get-SplunkLicenseStack threw an exception: $_"
            Write-Error $
_		}
	}
	End
	{
		Write-Verbose " [Get-SplunkLicenseStack] :: =========    End   ========="
	}

}    # Get-SplunkLicenseStack

#endregion Get-SplunkLicenseStack

#region Get-SplunkLicensePool

function Get-SplunkLicensePool
{
	<# .ExternalHelp ../Splunk-Help.xml #>

    [Cmdletbinding(DefaultParameterSetName="byFilter")]
    Param(

        [Parameter(Position=0,ParameterSetName="byFilter")]
        [STRING]$Filter = '.*',
    
        [Parameter(Position=0,ParameterSetName="byName")]
        [STRING]$Name,

        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
        [ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential
        
    )
    Begin 
    {

        Write-Verbose " [Get-SplunkLicensePool] :: Starting..."
        
        $ParamSetName = $pscmdlet.ParameterSetName
        switch ($ParamSetName)
        {
            "byFilter"  { $WhereFilter = { $_.PoolName -match $Filter } } 
            "byName"    { $WhereFilter = { $_.PoolName -ceq   $Name } }
        }

    }
    Process 
    {

            Write-Verbose " [Get-SplunkLicensePool] :: Parameters"
            Write-Verbose " [Get-SplunkLicensePool] ::  - ParameterSet = $ParamSetName"
            Write-Verbose " [Get-SplunkLicensePool] ::  - ComputerName = $ComputerName"
            Write-Verbose " [Get-SplunkLicensePool] ::  - Port         = $Port"
            Write-Verbose " [Get-SplunkLicensePool] ::  - Protocol     = $Protocol"
            Write-Verbose " [Get-SplunkLicensePool] ::  - Timeout      = $Timeout"
            Write-Verbose " [Get-SplunkLicensePool] ::  - Credential   = $Credential"
            Write-Verbose " [Get-SplunkLicensePool] ::  - WhereFilter  = $WhereFilter"

            Write-Verbose " [Get-SplunkLicensePool] :: Setting up Invoke-APIRequest parameters"
            $InvokeAPIParams = @{
                ComputerName = $ComputerName
                Port         = $Port
                Protocol     = $Protocol
                Timeout      = $Timeout
                Credential   = $Credential
                Endpoint     = '/services/licenser/pools' 
                Verbose      = $VerbosePreference -eq "Continue"
            }
                
            Write-Verbose " [Get-SplunkLicensePool] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
            
            try
            {
                [XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams
            }
            catch
            {
                Write-Verbose " [Get-SplunkLicensePool] :: Invoke-SplunkAPIRequest threw an exception: $_"
                Write-Error $
_            }
            try
            {
                if($Results -and ($Results -is [System.Xml.XmlDocument]))
                {
                    if($Results.feed.entry)
                    {
                        foreach($Entry in $Results.feed.entry)
                        {
                            $MyObj = @{
                                ComputerName = $ComputerName
                                PoolName     = $Entry.title
                                ID           = $Entry.link | Where-Object {$_.rel -eq "edit"} | Select-Object -expand href
                            }
                            Write-Verbose " [Get-SplunkLicensePool] :: Creating Hash Table to be used to create Splunk.SDK.License.Pool"
                            switch ($Entry.content.dict.key)
                            {
                                {$_.name -eq "description"}           { $Myobj.Add("Description",$_.'#text')        ; continue }
                                {$_.name -eq "slaves_usage_bytes"}    { $Myobj.Add("SlavesUsageBytes",$_.'#text')   ; continue }
                                {$_.name -eq "stack_id"}              { $Myobj.Add("StackID",$_.'#text')            ; continue }
                                {$_.name -eq "used_bytes"}            { $Myobj.Add("UsedBytes",$_.'#text')          ; continue }
                            }
                            
                            # Creating Splunk.SDK.License.Pool
                            $obj = New-Object PSObject -Property $MyObj
                            $obj.PSTypeNames.Clear()
                            $obj.PSTypeNames.Add('Splunk.SDK.License.Pool')
                            $obj | Where-Object $WhereFilter
                        }
                    }
                    else
                    {
                        Write-Verbose " [Get-SplunkLicensePool] :: No Messages Found"
                    }
                    
                }
                else
                {
                    Write-Verbose " [Get-SplunkLicensePool] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
                }
            }
            catch
            {
                Write-Verbose " [Get-SplunkLicensePool] :: Get-SplunkLicensePool threw an exception: $_"
                Write-Error $
_            }
    
    }
    End 
    {
        Write-Verbose " [Get-SplunkLicensePool] :: =========    End   ========="
    }
    
}   # Get-SplunkLicensePool

#endregion Get-SplunkLicensePool

#region Set-SplunkLicenseGroup

function Set-SplunkLicenseGroup
{
	<# .ExternalHelp ../Splunk-Help.xml #>

    [Cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param(

		[Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$True)]
		[STRING]$GroupName,

        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [String]$ComputerName = $SplunkDefaultConnectionObject.ComputerName,
        
        [Parameter()]
        [int]$Port            = $SplunkDefaultConnectionObject.Port,
        
        [Parameter()]
		[ValidateSet("http", "https")]
        [STRING]$Protocol     = $SplunkDefaultConnectionObject.Protocol,
        
        [Parameter()]
        [int]$Timeout         = $SplunkDefaultConnectionObject.Timeout,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential = $SplunkDefaultConnectionObject.Credential,
        
        [Parameter()]
        [SWITCH]$Force
        
    )
    Begin
	{
		Write-Verbose " [Get-SplunkLicenseGroup] :: Starting..."
	}
	Process
	{
		Write-Verbose " [Set-SplunkLicenseGroup] :: Parameters"
		Write-Verbose " [Set-SplunkLicenseGroup] ::  - ComputerName = $ComputerName"
		Write-Verbose " [Set-SplunkLicenseGroup] ::  - Port         = $Port"
		Write-Verbose " [Set-SplunkLicenseGroup] ::  - Protocol     = $Protocol"
		Write-Verbose " [Set-SplunkLicenseGroup] ::  - Timeout      = $Timeout"
		Write-Verbose " [Set-SplunkLicenseGroup] ::  - Credential   = $Credential"

		Write-Verbose " [Set-SplunkLicenseGroup] :: Setting up Invoke-APIRequest parameters"
		$InvokeAPIParams = @{
			ComputerName = $ComputerName
			Port         = $Port
			Protocol     = $Protocol
			Timeout      = $Timeout
			Credential   = $Credential
			Endpoint     = "/services/licenser/groups/${GroupName}"
			Verbose      = $VerbosePreference -eq "Continue"
		}
        
        $GroupPostParam = @{
            is_active = 1
        }
        
		Write-Verbose " [Set-SplunkLicenseGroup] :: Calling Invoke-SplunkAPIRequest @InvokeAPIParams"
		try
		{
            if($Force -or $PSCmdlet.ShouldProcess($ComputerName,"Setting Active Group to [$GroupName]"))
			{
			    [XML]$Results = Invoke-SplunkAPIRequest @InvokeAPIParams -Arguments $GroupPostParam -RequestType POST
            }
        }
        catch
		{
			Write-Verbose " [Set-SplunkLicenseGroup] :: Invoke-SplunkAPIRequest threw an exception: $_"
            Write-Error $
_		}
        try
        {
			if($Results -and ($Results -is [System.Xml.XmlDocument]))
			{
                Write-Host " [Set-SplunkLicenseGroup] :: Please restart Splunkd"
                Get-SplunkLicenseGroup -Name $GroupName
			}
			else
			{
				Write-Verbose " [Set-SplunkLicenseGroup] :: No Response from REST API. Check for Errors from Invoke-SplunkAPIRequest"
			}
		}
		catch
		{
			Write-Verbose " [Set-SplunkLicenseGroup] :: Set-SplunkLicenseGroup threw an exception: $_"
            Write-Error $
_		}
	}
	End
	{
		Write-Verbose " [Set-SplunkLicenseGroup] :: =========    End   ========="
	}

}    # Set-SplunkLicenseGroup

#endregion Set-SplunkLicenseGroup

#endregion SPlunk License
