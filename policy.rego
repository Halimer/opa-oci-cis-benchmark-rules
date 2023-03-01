package policy

# default allow = false
import input as tfplan

# allow { 
    
#     input.user.roles[_] == "admin"
    
#     }

msg := "Hello World"

# Consider exactly these network resource types
network_resource_types := {"oci_core_network_security_group", "oci_core_default_security_list", "oci_core_security_list" }

# Consider exactly these network resource types
iam_resource_types := {"oci_identity_policy", "oci_identity_group", "oci_identity_dynamic_group" }


# list of all network resources
network_resources[resource_type] := all {
    some resource_type
    network_resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
        name.change.after.ingress_security_rules[_].source == "0.0.0.0/0"
        name.change.after.ingress_security_rules[_].protocol == "6"

        # name.change.actions[_].after.comp
    ]
}


# list of all iam resources
iam_resources[resource_type] := all {
    some resource_type
    iam_resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
        contains(name.change.after.statements[_], "all-resources in tenancy")
    ]
}
