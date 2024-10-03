package cis.iam

import rego.v1

import input as tfplan

bad_combo := {"allow group to manage" , "all-resources"}

bad_pairs := {
    "com-admin": "to read all-resources",
    # "groups": "to manage groups in tenancy"
}

bad_combination_policies contains bad_policy.address if {
    bad_policy := tfplan.resource_changes[_]
    bad_policy.type == "oci_identity_policy"
    statements := bad_policy.change.after.statements
    some statement in statements
    some key, value in bad_pairs
    contains(statement, value)
    # contains(statement, value)
}