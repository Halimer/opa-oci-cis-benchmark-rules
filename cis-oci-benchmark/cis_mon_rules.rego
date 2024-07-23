package cis.monitoring

import rego.v1

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius := 7000

# weights assigned for each operation on each resource-type
weights := {

    # IAM Resources
    "oci_identity_policy": {"delete": 80, "create": 50, "modify" : 30}, 
    "oci_identity_user_group_membership": {"delete": 80, "create": 50, "modify" : 30}, 
    "oci_identity_group": {"delete": 80, "create": 50, "modify" : 30}, 
    "oci_identity_dynamic_group": {"delete": 80, "create": 50, "modify" : 30}, 
    "oci_identity_user": {"delete": 80, "create": 50, "modify" : 30},
    "oci_identity_authentication_policy": {"delete": 80, "create": 50, "modify" : 30},
    "oci_identity_domains_password_policy": {"delete": 80, "create": 50, "modify" : 30},
    # Network resources
    "oci_core_vcn": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_route_table": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_security_list": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_network_security_group": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_network_security_group_security_rule": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_drg": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_drg_attachment": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_internet_gateway": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_local_peering_gateway": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_nat_gateway": {"delete": 80, "create": 50, "modify" : 30},
    "oci_core_service_gateway": {"delete": 80, "create": 50, "modify" : 30}

}

# Consider exactly these resource types in calculations
cis_mon_types := {
    # IAM Resources
    "oci_identity_policy", 
    "oci_identity_user_group_membership", 
    "oci_identity_group", 
    "oci_identity_dynamic_group", 
    "oci_identity_user",
    "oci_identity_authentication_policy",
    "oci_identity_domains_password_policy",
    # Network resources
    "oci_core_vcn",
    "oci_core_route_table",
    "oci_core_security_list",
    "oci_core_network_security_group",
    "oci_core_network_security_group_security_rule",
    "oci_core_drg",
    "oci_core_drg_attachment",
    "oci_core_internet_gateway",
    "oci_core_local_peering_gateway",
    "oci_core_nat_gateway",
    "oci_core_service_gateway"
    }

#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default authz := false

authz if {
	score < blast_radius
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score := s if {
	all := [x |
		some resource_type
		crud := weights[resource_type]
		del := crud["delete"] * num_deletes[resource_type]
		new := crud["create"] * num_creates[resource_type]
		mod := crud["modify"] * num_modifies[resource_type]
		x := (del + new) + mod
	]
	s := sum(all)
}



####################
# Terraform Library
####################

# list of all resources of a given type
resources[resource_type] := all if {
	some resource_type
	cis_mon_types[resource_type]
	all := [name |
		name := tfplan.resource_changes[_]
		name.type == resource_type
	]
}

# number of creations of resources of a given type
num_creates[resource_type] := num if {
	some resource_type
	cis_mon_types[resource_type]
	all := resources[resource_type]
	creates := [res | res := all[_]; res.change.actions[_] == "create"]
	num := count(creates)
}

# number of deletions of resources of a given type
num_deletes[resource_type] := num if {
	some resource_type
	cis_mon_types[resource_type]
	all := resources[resource_type]
	deletions := [res | res := all[_]; res.change.actions[_] == "delete"]
	num := count(deletions)
}

# number of modifications to resources of a given type
num_modifies[resource_type] := num if {
	some resource_type
	cis_mon_types[resource_type]
	all := resources[resource_type]
	modifies := [res | res := all[_]; res.change.actions[_] == "update"]
	num := count(modifies)
}