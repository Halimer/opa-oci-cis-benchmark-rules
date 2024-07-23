package cis.storage

import rego.v1

import input as tfplan

storage_types := {

    "oci_objectstorage_bucket",
	"oci_file_storage_file_system",
	"oci_core_boot_volume",
	"oci_core_volume"
}

# Compute Sum
# total := s if {
# 	all := [x |
# 		some resource_type
# 		crud := storage_types[resource_type]
# 		del := num_deletes[resource_type]
# 		new := num_creates[resource_type]
# 		mod := num_modifies[resource_type]
# 		x := (del + new) + mod
# 	]
# 	s := sum(all)
# }


# list of all updates and creates of storage types
resources[resource_type] := sum if {
	some resource_type
	storage_types[resource_type]
	all := [name |
		name := tfplan.resource_changes[_]
		name.type == resource_type
		name.change.actions[_] in {"update", "create"}
	]
	sum := count(all)
}

# Object Storage Checks 
## Public Buckets 5.1.1
non_public_buckets := num if {
	all := [res |
		res := tfplan.resource_changes[_]
		res.type == "oci_objectstorage_bucket"
		res.change.actions[_] in {"update", "create"}
		res.change.after.access_type == "NoPublicAccess"
	]
	num := count(all)
}

## Encrypted Buckets 5.1.2
kms_encrypted_buckets := num if {
	all := [res |
		res := tfplan.resource_changes[_]
		res.type == "oci_objectstorage_bucket"
		res.change.actions[_] in {"update", "create"}
		res.change.after.kms_key_id != true
	]
	num := count(all)
}

## Versioned Buckets 5.1.3
versioned_buckets := num if {
	all := [res |
		res := tfplan.resource_changes[_]
		res.type == "oci_objectstorage_bucket"
		res.change.actions[_] in {"update", "create"}
		res.change.after.versioning == "Enabled"
	]
	num := count(all)
}

