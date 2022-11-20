/*output "rg_details" {
  value = local.rg_details
}
output "testing" {
  value = local.testing
}
output "resourcegroupnames" {
    value = local.resourcegroupnames
}
output "locations" {
  value = local.location
}
output "contains" {
  value = contains(local.resourcegroupnames,"az-EAST-us")
}
output "anotherlocation"{
  value = contains(local.resourcegroupnames,"az-east-us") ? index(local.resourcegroupnames,"az-east-us") : "not found"
}
output "result" {
  value = element(local.location,index(local.resourcegroupnames,"az-east-us"))
}
output "name" {
  value = "the first resource group name are ${local.resourcegroupnames[0]}"
}
output "lookup" {
  value = lookup(local.rg_details[0],"resourcegroupname","key not found")
}
output "zipmap" {
  value = zipmap(local.resourcegroupnames,local.location)
}
/*
testing = tolist([
  {
    "location" = "eastus"
    "resouregroupname" = "az-east-us"
  {
    "location" = "westus"
    "resouregroupname" = "az-west-us"
  },
  {
    "location" = "centralus"
    "resouregroupname" = "az-central-us"
  },
])
*/