require 'pathname'

Puppet::Type.newtype(:dsc_cwds_clientlogging) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_ClientLogging resource type.
    Automatically generated from
    'cWDS/DSCResources/cWDS_ClientLogging/cWDS_ClientLogging.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_enabled is a required attribute') if self[:dsc_enabled].nil?
      fail('dsc_logginglvl is a required attribute') if self[:dsc_logginglvl].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_ClientLogging' end
  def dscmeta_resource_name; 'cWDS_ClientLogging' end
  def dscmeta_module_name; 'cWDS' end
  def dscmeta_module_version; '1.1' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    defaultto { :present }
  end

  # Name:         PsDscRunAsCredential
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_psdscrunascredential) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "PsDscRunAsCredential"
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("Credential", value)
    end
  end

  # Name:         Enabled
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Yes", "No"]
  newparam(:dsc_enabled) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Enabled - Valid values are Yes, No."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No")
      end
    end
  end

  # Name:         LoggingLvl
  # Type:         string
  # IsMandatory:  True
  # Values:       ["None", "Info", "Warnings", "Errors"]
  newparam(:dsc_logginglvl) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "LoggingLvl - Valid values are None, Info, Warnings, Errors."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['None', 'none', 'Info', 'info', 'Warnings', 'warnings', 'Errors', 'errors'].include?(value)
        fail("Invalid value '#{value}'. Valid values are None, Info, Warnings, Errors")
      end
    end
  end

  # Name:         DesiredState
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_desiredstate) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "DesiredState"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_cwds_clientlogging).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
