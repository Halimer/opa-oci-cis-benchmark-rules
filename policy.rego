package policy

# default allow = false
import input as tfplan

default testing = false
default testing2 = false

import future.keywords.every


testing {
    1 == 2
}

testing2 {
    input.user.roles[_] == "admin"
}


# allow[msg] { 
    
#     input.user.roles[_] == "admin"
    
#     }

# msg := "Your admin"

# # Consider exactly these network resource types
network_resource_types := {"oci_core_network_security_group", "oci_core_default_security_list", "oci_core_security_list" }

# Consider exactly these IAM resource types
iam_policy_resources := {"oci_identity_policy"}


# iam_policies[resource_type] := all {
#     some resource_type
#     iam_policy_resources[resource_type ]
# }


# no_bitcoin_miners_using_every if {
#     every app in apps {
#         app.name != "bitcoin-miner"
#     }
# }



bucket_is_secure(bucket) := true {
    bucket.change.after.access_type == "PublicAccess"
    bucket.change.after_unknown.kms_key_id == false
}


secure_buckets {
    bucket := tfplan.resource_changes[_].type == "oci_objectstorage_bucket"
}   


public_bucket[resource_name] {
    # Iterate through each change in the Terraform plan
    item := input.resource_changes[_]
    
    # Check if the change is related to an Object Storage bucket
    item.type == "oci_objectstorage_bucket"
    
    # Extract the resource name (the AWS S3 bucket name)
    resource_name := item.change.after.name
    
    # Check if the access_type is PublicAccess
    item.change.after.access_type == "PublicAccess"
}

unencrypted_bucket[resource_name] {
    # Iterate through each change in the Terraform plan
    item := input.resource_changes[_]
    
    # Check if the change is related to an Object Storage bucket
    item.type == "oci_objectstorage_bucket"
    
    # Extract the resource name (the AWS S3 bucket name)
    resource_name := item.change.after.name
    
    # Check if the access_type is PublicAccess
    item.change.after_unknown.kms_key_id == true
}


# # list of all network resources
# network_resources[resource_type] := all {
#     some resource_type
#     network_resource_types[resource_type]
#     all := [name |
#         name:= tfplan.resource_changes[_]
#         name.type == resource_type
#         name.change.after.ingress_security_rules[_].source != "0.0.0.0/0"
#         name.change.after.ingress_security_rules[_].protocol == "6"

#         # name.change.actions[_].after.comp
#     ]
# }


# # list of all iam resources
# iam_resources[resource_type] := all {
#     some resource_type
#     iam_resource_types[resource_type]
#     all := [name |
#         name:= tfplan.resource_changes[_]
#         name.type == resource_type
#         contains(name.change.after.statements[_], "to manage all-resources in tenancy")
#     ]
# }

# iam_policies {
#     all := [name |
#         name:= tfplan.resource_changes[_]
#         name.type == "oci_identity_policy"
#     ]
# }


# test := count(iam_resources)
