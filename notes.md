# Current rules

Run cis_mon_rules.regio
`opa exec --decision cis/monitoring/score --bundle cis-oci-benchmark/ core-lz-tf-plan.json`

# Basic Policy
## Package Name
```
package <name>
```

## Basic policy, default is to return `true`
```
default <policy-name> <result>
<policy-name> = <result> {
    <condition>
}
```
## Sample policy no INPUT
```
package policy
default testing = false
testing = true {
    1 == 1
}

```
## Sample policy with input

```
package policy
default testing2 = false
testing2 = true {
    input.user.roles[_] == "admin"  # iterating through multiple roles in an input of roles
    input.user.roles[i] == # if we cared about the index

}


```


## Basic Package example
### Two Globals
`--data` - contains all polices fed to policy analyzer
`--input` - input 

`opa eval --data <rego file name> data.<package name>.rule>`
### Example All data
`opa eval --data policy.rego data.policy.testing`

## Example outputs just result
`opa eval --format raw --data policy.rego 'data.policy.testing'`

## With a file as input
`opa eval --format raw --data policy.rego --input user.json 'data.policy.testing2'`


# Basic Policy Testing Package
## Notes
- Test policies should start with `test_`
- best practice to put them in a seperate package 
- import the policy you want to test

## Example Test Package
- Without any input provide testing2 should be false

```
package policy_test

import data.policy.testing2

test_testing2_is_false_by_default {
    testing2 == false
}

```
## Cleaner
```
package policy_test

import data.policy.testing2

test_testing2_is_false_by_default {
    not testing2
}

```


## Execute test 
`opa test *.rego`



## Examples

```resource_types := {"aws_autoscaling_group", "aws_instance", "aws_iam", "aws_launch_configuration"}

resources[resource_type] := all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}
```


```
Here's a pseudo-code explanation of what this code does:

    Initialize a set called resource_types with the names of resource types that you want to manage, such as "aws_autoscaling_group," "aws_instance," "aws_iam," and "aws_launch_configuration."

    Initialize an empty dictionary called resources.

    Iterate over each resource_type in the resource_types set:

    a. For each resource_type, create a sub-set of resources called all.

    b. In this sub-set, filter out resource names (name) from a source called tfplan.resource_changes.

    c. Only include name if it has a type matching the current resource_type.

    d. Store this filtered list of resource names as the value for the current resource_type in the resources dictionary.
    ```

## Sample 1
### Code
    ```
    # Define the rule to find the type of bucket in the Terraform plan
find_bucket_type[resource_type] {
    # Iterate over each change in the Terraform plan
    change := input.resource_changes[_]
    
    # Check if the change is related to an AWS S3 bucket
    change.type == "aws_s3_bucket"
    
    # Extract the resource type (in this case, it's "aws_s3_bucket")
    resource_type := change.type
}
    ```
### Meaing
```In this Rego policy:

    The package is named find_bucket_type, and it contains a rule named find_bucket_type.

    The rule iterates through each change in the Terraform plan using _ as the iterator variable.

    It checks if the change.type is equal to "aws_s3_bucket". This condition identifies changes related to AWS S3 buckets.

    If the condition is met, it sets resource_type to "aws_s3_bucket".

Now, you can use this Rego policy to find AWS S3 bucket changes in a Terraform JSON plan by passing the plan as input to the Rego policy evaluator. The find_bucket_type rule will return the resource type when it encounters an AWS S3 bucket resource in the plan.

Please note that this Rego policy assumes that the Terraform JSON plan follows the typical structure where each resource change has a type field indicating the resource type. You may need to adapt the policy to your specific Terraform plan format if it differs.```

## Sample 2
### Code
```
package find_public_s3_buckets

# Define the rule to find AWS S3 buckets with PublicAccess
public_s3_bucket[resource_name] {
    # Iterate through each change in the Terraform plan
    change := input.resource_changes[_]
    
    # Check if the change is related to an AWS S3 bucket
    change.type == "aws_s3_bucket"
    
    # Extract the resource name (the AWS S3 bucket name)
    resource_name := change.name
    
    # Check if the access_type is PublicAccess
    change.change.after.access_type == "PublicAccess"
}
```

### Explain
1. The package is named find_public_s3_buckets, and it contains a rule named public_s3_bucket.

2. The rule iterates through each change in the Terraform plan using _ as the iterator variable.

3. It checks if the change.type is equal to "aws_s3_bucket". This condition identifies changes related to AWS S3 buckets.

4. If the condition is met, it extracts the AWS S3 bucket's name as resource_name.

5. It further checks if the access_type in the change.change.after field is equal to "PublicAccess". This condition identifies AWS S3 buckets with public access.

Now, you can use this modified Rego policy to find AWS S3 buckets with public access in a Terraform JSON plan by passing the plan as input to the Rego policy evaluator. The public_s3_bucket rule will return the names of the AWS S3 buckets with public access when it encounters such resources in the plan.

Please make sure that the structure of your Terraform JSON plan includes the access_type field as indicated in the policy for this to work correctly.